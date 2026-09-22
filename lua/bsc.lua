-- Bluespec (bsc) diagnostics source for none-ls.
--
-- Runs bsc on the buffer (via a temp file), parses its stderr into
-- diagnostics, and picks up per-file compilation flags from an optional
-- `bsc_compile_commands.json` database from an explicit directory, upward
-- from the source file, or in the nearest ancestor's build/ directory.
--
-- Database format — same shape as clang's compile_commands.json, but in a
-- distinct file so clangd never picks it up:
--
--   [
--     {
--       "directory": "/abs/path/of/build/root",
--       "file": "src/Core.bsv",
--       "arguments": ["bsc", "-p", ".:%/Libraries:../lib", "-D", "SIMULATION"]
--     }
--   ]
--
-- Rules:
--   * `file` is resolved relative to `directory` (or the database's own
--     directory when `directory` is omitted); `directory` is also used as the
--     cwd of the diagnostic run, so relative -p entries keep working.
--   * `arguments` (an argv array) is preferred. A `command` string is
--     accepted as a fallback but is only split on whitespace — no shell
--     quoting support — so have the build tool emit `arguments`.
--   * Output-related flags (-bdir, -o, -g, ...), backend selection and the
--     source file itself are stripped from the entry; the diagnostic run
--     supplies its own.
--
-- Without a database entry the source falls back to a default search path of
-- ".", the bsc libraries, the file's own directory, and $BSC_BDIR.

local M = {}

---------------------------------------------------------------------------
-- Output parsing
---------------------------------------------------------------------------

local SEVERITY = {
  Error = vim.diagnostic.severity.ERROR,
  Warning = vim.diagnostic.severity.WARN,
  Message = vim.diagnostic.severity.INFO,
}

local function is_same_file(a, b) return vim.fs.normalize(a) == vim.fs.normalize(b) end

--- Parse bsc stderr into none-ls diagnostics.
---
--- bsc messages look like:
---   Error: "Foo.bsv", line 12, column 8: (T0020)
---     message body, indented by two spaces,
---     possibly spanning several lines
--- or, for messages with no source position:
---   Warning: Unknown position: (S0001)
---     message body
--- Progress noise ("checking package dependencies", ...) is interleaved on
--- stderr as well and must be ignored.
---
---@param output string? raw stderr from bsc
---@param source_path string? path the compiled file was passed as (the temp
---       file); diagnostics for other files (dependencies built by -u) are
---       anchored to line 1 with their real location in the message
---@return table[] diagnostics
function M.parse_output(output, source_path)
  if not output or output == "" then return {} end

  local entries = {}
  local current

  local function flush()
    if current then
      current.message = vim.trim(current.message)
      table.insert(entries, current)
      current = nil
    end
  end

  for _, line in ipairs(vim.split(output, "\n", { plain = true })) do
    local sev, filename, row, col, code = line:match '^(%a+): "(.-)", line (%d+), column (%d+): %((%w+)%)'
    local rest
    if not sev then
      sev, rest = line:match "^(%a+): (.*)"
    end

    if sev and SEVERITY[sev] then
      flush()
      current = {
        severity = SEVERITY[sev],
        filename = filename,
        row = tonumber(row),
        col = tonumber(col),
        -- positionless headers still carry a code, e.g. "Command line: (S0008)"
        code = code or (rest and rest:match "%((%w+)%)%s*$"),
        message = "",
      }
    elseif current then
      -- empty lines are paragraph breaks within a message
      local body = line == "" and "" or line:match "^  (.*)"
      if body then
        current.message = current.message == "" and body or current.message .. "\n" .. body
      else
        -- non-indented, non-header line: progress noise ends the message
        flush()
      end
    end
  end
  flush()

  local diagnostics = {}
  for _, e in ipairs(entries) do
    local diagnostic = {
      row = e.row or 1,
      col = e.col or 1,
      severity = e.severity,
      code = e.code,
      source = "bsc",
      message = e.message,
    }
    if e.filename and source_path and not is_same_file(e.filename, source_path) then
      -- Error in a dependency compiled via -u: its positions don't apply to
      -- this buffer, so anchor it at the top and point at the real location.
      diagnostic.row, diagnostic.col = 1, 1
      diagnostic.message = ("%s:%d:%d: %s"):format(e.filename, e.row, e.col, e.message)
    end
    table.insert(diagnostics, diagnostic)
  end
  return diagnostics
end

---------------------------------------------------------------------------
-- Compilation database
---------------------------------------------------------------------------

local DB_NAME = "bsc_compile_commands.json"

-- Flags the diagnostic run must control itself: backend selection, update
-- mode, elaboration, and anything that writes build outputs next to the sources.
local STRIP = {
  ["-u"] = false,
  ["-elab"] = false,
  ["-sim"] = false,
  ["-verilog"] = false,
  ["-systemc"] = false,
  -- these take a value that must be dropped too
  ["-bdir"] = true,
  ["-vdir"] = true,
  ["-simdir"] = true,
  ["-info-dir"] = true,
  ["-fdir"] = true,
  ["-o"] = true,
  ["-g"] = true,
  ["-e"] = true,
}

---@param argv string[] entry arguments, argv[1] being the program name
---@return string[] flags safe to reuse for a diagnostic run
local function sanitize_args(argv)
  local flags = {}
  local skip_value = false
  for i, arg in ipairs(argv) do
    if skip_value then
      skip_value = false
    elseif STRIP[arg] ~= nil then
      skip_value = STRIP[arg]
    elseif not (i == 1 and not vim.startswith(arg, "-")) and not arg:match "%.bsv$" then
      table.insert(flags, arg)
    end
  end
  return flags
end

local db_cache = {} -- db path -> { mtime = integer, entries = { [file] = entry } }

---@return table<string, { directory: string, flags: string[] }>?
local function load_db(db_path)
  local stat = vim.uv.fs_stat(db_path)
  if not stat then return nil end

  local cached = db_cache[db_path]
  if cached and cached.mtime == stat.mtime.sec then return cached.entries end

  local ok, decoded = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(db_path), "\n")) end)
  if not ok or type(decoded) ~= "table" then
    vim.notify(("bsc: cannot parse %s: %s"):format(db_path, decoded), vim.log.levels.WARN)
    return nil
  end

  local entries = {}
  for _, entry in ipairs(decoded) do
    local argv = entry.arguments or (entry.command and vim.split(entry.command, "%s+", { trimempty = true }))
    if type(entry) == "table" and type(entry.file) == "string" and argv then
      local directory = entry.directory or vim.fs.dirname(db_path)
      local file = vim.fs.normalize(entry.file)
      if not vim.startswith(file, "/") then file = vim.fs.joinpath(directory, file) end
      entries[vim.fs.normalize(file)] = {
        directory = directory,
        flags = sanitize_args(argv),
      }
    end
  end

  db_cache[db_path] = { mtime = stat.mtime.sec, entries = entries }
  return entries
end

--- Look up the compilation database entry for a source file.
---@param fname string absolute path of the source file
---@param compile_commands_dir string? database directory, relative to Neovim cwd
---@return { directory: string, flags: string[] }?
function M.lookup(fname, compile_commands_dir)
  fname = vim.fs.normalize(fname)
  local db_path
  if compile_commands_dir then
    local candidate = vim.fs.joinpath(vim.fn.fnamemodify(compile_commands_dir, ":p"), DB_NAME)
    if vim.fn.filereadable(candidate) == 1 then db_path = candidate end
  end
  local source_dir = vim.fs.dirname(fname)
  db_path = db_path or vim.fs.find(DB_NAME, { upward = true, path = source_dir })[1]
  if not db_path then
    local dir = source_dir
    while dir do
      local candidate = vim.fs.joinpath(dir, "build", DB_NAME)
      if vim.fn.filereadable(candidate) == 1 then
        db_path = candidate
        break
      end
      local parent = vim.fs.dirname(dir)
      if parent == dir then break end
      dir = parent
    end
  end
  if not db_path then return nil end
  local entries = load_db(db_path)
  return entries and entries[fname]
end

---------------------------------------------------------------------------
-- none-ls source
---------------------------------------------------------------------------

local function default_flags()
  local path = { ".", "%/Libraries", "$DIRNAME" }
  if vim.env.BSC_BDIR then table.insert(path, vim.env.BSC_BDIR) end
  return { "-p", table.concat(path, ":") }
end

--- Build the none-ls diagnostics source. Pass the result to none-ls
--- `config.sources`.
---@param opts { compile_commands_dir?: string }?
function M.source(opts)
  opts = opts or {}
  local h = require "null-ls.helpers"
  local methods = require "null-ls.methods"

  -- keep .bo build products out of the source tree
  local bdir = vim.fn.tempname()
  vim.fn.mkdir(bdir, "p")

  return h.make_builtin {
    name = "bsc",
    meta = {
      url = "https://github.com/B-Lang-org/bsc",
      description = "Bluespec Compiler",
    },
    method = methods.internal.DIAGNOSTICS,
    filetypes = { "bsv" },
    condition = function() return vim.fn.executable "bsc" == 1 end,
    generator_opts = {
      command = "bsc",
      to_stdin = false,
      from_stderr = true,
      to_temp_file = true,
      format = "raw",
      cwd = function(params)
        local entry = M.lookup(params.bufname, opts.compile_commands_dir)
        return entry and entry.directory
      end,
      args = function(params)
        local entry = M.lookup(params.bufname, opts.compile_commands_dir)
        local args = entry and vim.deepcopy(entry.flags) or default_flags()
        return vim.list_extend(args, {
          "-u",
          "-sim",
          "-bdir",
          bdir,
          -- S0001/S0080: file name does not match package name (always the
          -- case for the temp file); S0089: -u with an out-of-date import
          "-suppress-warnings",
          "S0001:S0080:S0089",
          "$FILENAME",
        })
      end,
      on_output = function(params, done) done(M.parse_output(params.output, params.temp_path)) end,
    },
    factory = h.generator_factory,
  }
end

return M

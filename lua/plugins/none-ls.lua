-- Customize None-ls sources

local function bluespec_diagnostic()
  local h = require "null-ls.helpers"
  local methods = require "null-ls.methods"

  local DIAGNOSTICS = methods.internal.DIAGNOSTICS

  local bdirs = {
    ".",
    "%/Libraries",
    "$DIRNAME",
    os.getenv "BSC_BDIR",
  }

  return h.make_builtin {
    name = "bsc",
    meta = {
      url = "https://github.com/B-Lang-org/bsc",
      description = "Bluespec Compiler",
    },
    method = DIAGNOSTICS,
    filetypes = { "bsv" },
    generator_opts = {
      command = "bsc",
      args = {
        "-sim",
        "-bdir",
        "/tmp",
        "-p",
        table.concat(bdirs, ":"),
        "-u",
        "-suppress-warnings",
        "S0089:S0080",
        "$FILENAME",
      },
      to_stdin = false,
      from_stderr = true,
      to_temp_file = true,
      format = "raw",
      on_output = function(params, done)
        local output = params.output
        if not output then return done() end

        local diagnostics = {}
        local severity = {
          Error = 1,
          Warning = 2,
        }

        local next = next
        local lines = vim.split(output, "\n")

        local diagnostic = {}

        for _, line in ipairs(lines) do
          if line ~= "" then
            local err, filename, row, col, code = line:match '(.*): "(.*)", line (%d*), column (%d*): %((.*)%)'

            if row ~= nil and col ~= nil then
              -- parse succeed, line is header
              if next(diagnostic) ~= nil then
                -- if previous diagnostic exists, insert into diagnostics
                table.insert(diagnostics, diagnostic)
              end

              diagnostic = {
                filename = filename,
                row = row,
                col = col,
                code = code,
                source = "bsv",
                message = "",
                severity = severity[err],
              }
            else
              -- parse failed, line is message
              if next(diagnostic) ~= nil then
                -- make sure diagnostics table is not empty
                diagnostic.message = diagnostic.message .. string.sub(line, 3) .. "\n"
              end
            end
          end
        end

        if next(diagnostic) ~= nil then
          -- if previous diagnostic exists, insert into diagnostics
          table.insert(diagnostics, diagnostic)
        end

        done(diagnostics)
      end,
    },
    factory = h.generator_factory,
  }
end

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, config)
    -- config variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    config.sources = {
      -- Set a formatter
      -- null_ls.builtins.formatting.stylua,
      -- null_ls.builtins.formatting.prettier,
      null_ls.builtins.diagnostics.verilator.with {
        extra_args = { "-Wall", "-I$DIRNAME" },
        method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
      },

      null_ls.register(bluespec_diagnostic()),
    }
    return config -- return final config table
  end,
}

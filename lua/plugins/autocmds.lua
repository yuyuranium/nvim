local function get_format_setting(textwidth, shiftwidth)
  return function()
    textwidth = textwidth or 80
    shiftwidth = shiftwidth or 2
    vim.opt_local.textwidth = textwidth
    vim.opt_local.colorcolumn = { textwidth }
    vim.opt_local.shiftwidth = shiftwidth
    vim.opt_local.tabstop = shiftwidth
  end
end

local autocmds = {
  format_option = {
    {
      event = "FileType",
      pattern = { "c", "cpp" },
      callback = get_format_setting(80, 2),
    },
    {
      event = "FileType",
      pattern = { "lua", "bsv" },
      callback = get_format_setting(100, 2),
    },
    {
      event = "FileType",
      pattern = { "gitcommit" },
      callback = get_format_setting(72),
    },
    {
      event = "FileType",
      pattern = { "gitcommit", "markdown" },
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
      end,
    },
  },
  foo = {
    {
      event = "FileType",
      callback = function() vim.opt_local.formatoptions = vim.opt_local.formatoptions - "r" - "o" end,
    },
  },
  -- OSC52Yank = {
  --   {
  --     event = "TextYankPost",
  --     desc = "Send yanked text to terminal via OSC 52",
  --     callback = function()
  --       local event = vim.v.event
  --       -- Trigger only with explicit yank operator 'y'
  --       if event.operator == "y" then
  --         local text = table.concat(event.regcontents, "\n")
  --         local b64 = vim.base64.encode(text) -- Requires Neovim 0.10+
  --         local osc52_seq = string.format("\x1b]52;c;%s\x07", b64)
  --         io.stderr:write(osc52_seq)
  --       end
  --     end,
  --   },
  -- },
}

return {
  "AstroNvim/astrocore",
  opts = {
    autocmds = autocmds,
  },
}

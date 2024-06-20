local autocmds = {
  format_option = {
    {
      event = "FileType",
      pattern = { "c", "cpp" },
      callback = function()
        vim.opt_local.textwidth = 80
        vim.opt_local.colorcolumn = { 80 }
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
      end,
    },
    {
      event = "FileType",
      pattern = { "gitcommit" },
      callback = function()
        vim.opt_local.textwidth = 72
        vim.opt_local.colorcolumn = { 72 }
      end,
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
}

return {
  "AstroNvim/astrocore",
  opts = {
    autocmds = autocmds,
  },
}

-- Custom Neovim options

local options = {
  opt = {
    -- set to true or false etc.
    relativenumber = false, -- sets vim.opt.relativenumber
    number = true, -- sets vim.opt.number
    spell = false, -- sets vim.opt.spell
    signcolumn = "yes:1",
    wrap = false, -- sets vim.opt.wrap
    backup = false,
    clipboard = "unnamedplus",
    conceallevel = 0,
    fileencoding = "utf-8",
    smartcase = true,
    smartindent = true,
    swapfile = false,
    undofile = true,
    numberwidth = 4,
    scrolloff = 3,
    sidescrolloff = 8,
    textwidth = 100,
    linebreak = true,
    cmdheight = 1,
    termguicolors = true,
  },
  g = {
    mapleader = " ", -- sets vim.g.mapleader
    autoformat_enabled = true, -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
    cmp_enabled = true, -- enable completion at start
    autopairs_enabled = true, -- enable autopairs at start
    diagnostics_mode = 3, -- set the visibility of diagnostics in the UI (0=off, 1=only show in status line, 2=virtual text off, 3=all on)
    icons_enabled = true, -- disable icons in the UI (disable if no nerd font is available, requires :PackerSync after changing)
    ui_notifications_enabled = true, -- disable notifications when toggling UI elements
    resession_enabled = false, -- enable experimental resession.nvim session management (will be default in AstroNvim v4)
  },
  o = {
    exrc = true,
  },
}

return {
  {
    "AstroNvim/astrocore",
    opts = {
      options = options,
    },
  },
}

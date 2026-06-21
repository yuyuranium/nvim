return {
  {
    "max397574/better-escape.nvim",
    enabled = false,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      local ft = require "Comment.ft"
      ft.bsv = { "//%s", "/*%s*/" }
    end,
  },
  {
    "mrjones2014/smart-splits.nvim",
    opts = {
      at_edge = "stop",
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        delete = { text = "_" },
        topdelete = { text = "‾" },
      },
    },
  },
  {
    -- AstroNvim v6 uses mini.icons (it mocks nvim-web-devicons), so the custom bsv
    -- icon is registered here by filetype and extension. mini.icons colors via
    -- highlight groups; MiniIconsBlue approximates the previous #51a0cf.
    "nvim-mini/mini.icons",
    opts = {
      filetype = {
        bsv = { glyph = "󰘚", hl = "MiniIconsBlue" },
      },
      extension = {
        bsv = { glyph = "󰘚", hl = "MiniIconsBlue" },
      },
    },
  },
  {
    "yuyuranium/vim-bsv",
    event = "BufRead",
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    opts = {
      highlight = {
        pattern = [[.*<(KEYWORDS).*:]],
      },
    },
  },
  {
    "chomosuke/typst-preview.nvim",
    lazy = false, -- or ft = 'typst'
    version = "1.*",
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },
}

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
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {
        bsv = {
          icon = "󰘚",
          color = "#51a0cf",
          cterm_color = "74",
          name = "BSV",
        },
      },
    },
  },
  {
    "yuyuranium/vim-bsv",
    event = "BufRead",
  },
}

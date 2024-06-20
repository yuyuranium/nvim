-- Custom key mappings

local mappings = {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map

    -- navigate buffer tabs with `<TAB>` and `<S-TAB>`
    ["<TAB>"] = {
      function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Next buffer",
    },
    ["<S-TAB>"] = {
      function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
      desc = "Previous buffer",
    },

    -- Easy way to go to line head and tail
    ["H"] = { "^", desc = "Go to line head" },
    ["L"] = { "$", desc = "Go to line end" },

    -- Use Q to close the buffer
    ["Q"] = { function() require("astrocore.buffer").close() end, desc = "Close the buffer" },

    -- mappings seen under group name "Buffer"
    ["<leader>bD"] = {
      function()
        require("astroui.status").heirline.buffer_picker(function(bufnr) require("astrocore.buffer").close(bufnr) end)
      end,
      desc = "Pick to close",
    },
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
    ["<leader>h"] = { "<cmd>nohls<cr>", desc = "Disable highlight search" },
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
  v = {
    -- stay in indent mode
    [">"] = { ">gv" },
    ["<"] = { "<gv" },

    -- Easy way to go to line head and tail
    ["H"] = { "^", desc = "Go to line head" },
    ["L"] = { "$", desc = "Go to line end" },

    -- better paste
    ["p"] = { "P" },
  },
}

return {
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = mappings,
    },
  },
}

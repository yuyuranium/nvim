return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  -- nvim-surround v4 removed the `keymaps` field from setup(); default mappings are
  -- now created on load. All of the previous custom keymaps matched the defaults
  -- except visual mode, so we only disable the visual defaults (S / gS) and remap
  -- them to s / gs via the provided <Plug> mappings.
  init = function() vim.g.nvim_surround_no_visual_mappings = true end,
  config = function()
    require("nvim-surround").setup {}
    vim.keymap.set("x", "s", "<Plug>(nvim-surround-visual)", { desc = "Surround selection" })
    vim.keymap.set("x", "gs", "<Plug>(nvim-surround-visual-line)", { desc = "Surround selection (line)" })
  end,
}

-- Customize Treesitter
-- NOTE: AstroNvim v6 uses the `main` branch of nvim-treesitter, which is now just a
-- parser-download utility. Treesitter features (highlight/indent/textobjects) are
-- configured through AstroCore's `treesitter` table instead of nvim-treesitter itself.

---@type LazySpec
return {
  -- Treesitter features + parsers to ensure are installed.
  -- The `c`, `lua`, and `vim` parsers are already in AstroNvim's defaults; AstroCore
  -- extends (not replaces) `ensure_installed`, so we only need to add the extras.
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      treesitter = {
        ensure_installed = {
          "cpp",
        },
      },
    },
  },
  -- Register the custom out-of-tree Bluespec (bsv) parser. On the `main` branch this is
  -- done via the `User TSUpdate` event rather than `get_parser_configs()`. With
  -- `auto_install` on (AstroNvim default), opening a `bsv` buffer installs it on demand;
  -- you can also run `:TSInstall bsv` manually.
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          require("nvim-treesitter.parsers").bsv = {
            install_info = {
              url = "https://github.com/yuyuranium/tree-sitter-bsv",
              branch = "main",
              -- files default to { "src/parser.c" }; bsv has no external scanner
            },
          }
        end,
      })
    end,
  },
}

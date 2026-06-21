-- Customize Mason plugins
-- NOTE: AstroNvim v6 manages Mason tool installation through `mason-tool-installer`
-- (formatters/linters/debuggers) and `mason-lspconfig` (language servers). The old
-- `mason-null-ls`/`mason-nvim-dap` bridges have been removed.

---@type LazySpec
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "mason-org/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      ensure_installed = {
        -- add more arguments for adding more language servers
      },
    },
  },
  -- use mason-tool-installer to ensure formatters/linters/debuggers are installed
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      ensure_installed = {
        "stylua",
        -- add more arguments for adding more tools (formatters, linters, DAPs)
      },
    },
  },
}

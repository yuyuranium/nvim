-- Customize None-ls sources

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

      -- Bluespec compiler diagnostics; see lua/bsc.lua for the
      -- bsc_compile_commands.json per-file flag database format
      require("bsc").source(),
    }
    return config -- return final config table
  end,
}

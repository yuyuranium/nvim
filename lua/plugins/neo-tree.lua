local get_icon = require("astroui").get_icon

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    default_component_configs = {
      modified = { symbol = get_icon "FileModified" },
      git_status = {
        symbols = {
          untracked = get_icon "GitUnstaged",
        },
      },
    },
    window = {
      mappings = {
        ["<TAB>"] = "next_source",
        ["<S-TAB>"] = "prev_source",
        ["l"] = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" then
            require("neo-tree.sources.filesystem").toggle_directory(state, node)
          else
            local commands = require "neo-tree.sources.common.commands"
            commands.open(state, commands.toggle_directory)
          end
        end,
        v = "open_vsplit",
      },
    },
  },
}

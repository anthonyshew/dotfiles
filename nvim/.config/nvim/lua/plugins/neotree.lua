return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    close_if_last_window = true,
    window = {
      position = "right",
    },
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = false,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          -- '.git',
          ".DS_Store",
        },
        never_show = {
          ".DS_Store",
          ".git",
        },
      },
    },
  },
}

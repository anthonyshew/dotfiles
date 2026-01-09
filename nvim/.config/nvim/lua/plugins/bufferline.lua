return {
  "bufferline.nvim",
  opts = {
    options = {
      always_show_bufferline = true,
      diagnostics = false,
      buffer_close_icon = "",
      offsets = {
        {
          filetype = "neo-tree",
          text = "",
          separator = true,
          text_align = "right",
        },
      },
    },
    highlights = {
      modified = { fg = "#A6B5FF" },
      modified_visible = { fg = "#A6B5FF" },
      modified_selected = { fg = "#A6B5FF" },
    },
  },
}

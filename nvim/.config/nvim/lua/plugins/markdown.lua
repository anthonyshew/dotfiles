return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
}

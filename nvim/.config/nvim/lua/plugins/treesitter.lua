return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(parser)
        return parser ~= "jsonc"
      end, opts.ensure_installed or {})
    end,
  },
}

return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = false,
    },
    diagnostics = {
      float = {
        border = "rounded",
      },
    },
    servers = {
      vtsls = {
        settings = {
          typescript = {
            tsserver = {
              maxTsServerMemory = 8192,
            },
          },
        },
      },
    },
  },
}

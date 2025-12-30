return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  enabled = true,
  opts = {
    notifier = { enabled = true, width = { min = 0, max = 0 }, height = { min = 0, max = 0 } },
    lazygit = {
      enabled = true,
      win = {
        position = "float",
        width = 0,
        height = 0,
        border = "none",
        backdrop = false,
      },
    },
  },
  keys = {
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>gl",
      function()
        Snacks.lazygit.log()
      end,
      desc = "Lazygit log",
    },
  },
}

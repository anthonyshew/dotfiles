return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    local custom_iceberg_dark = require("lualine.themes.iceberg_dark")
    custom_iceberg_dark.normal.c.bg = "#000000"
    opts.options = {
      theme = custom_iceberg_dark,
    }

    opts.sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = { "diagnostics", "diff", "branch" },
      lualine_z = { "progress", "mode" },
    }
  end,
}

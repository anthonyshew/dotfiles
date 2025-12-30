return {
  {
    "projekt0n/github-nvim-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({
        groups = {
          all = {
            -- https://github.com/projekt0n/github-nvim-theme/blob/d832925e77cef27b16011a8dfd8835f49bdcd055/lua/github-theme/group/editor.lua#L25
            Normal = { bg = "#000000", fg = "#ffffff" },
            NormalFloat = { bg = "#000000", fg = "#ffffff" },
            NormalNC = { bg = "#000000", fg = "#ffffff" },
            NormalSB = { bg = "#000000", fg = "#ffffff" },
            Pmenu = { bg = "#000000" },
            PmenuSel = { bg = "#1E1E1E" },
            -- PmenuThumb = { bg = "#1E1E1E" },
            PmenuThumb = { bg = "#000000" },
          },
        },
      })

      vim.cmd("colorscheme github_dark_default")
      vim.cmd("hi CursorLine guibg=#1a1a1a")
    end,
  },
}

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.termguicolors = true

-- Decrease updatetime of the swapfile to 250ms
vim.opt.updatetime = 250

-- Enable persistent undo history
vim.opt.undofile = true

-- Specify root directory
vim.g.root_spec = { "cwd" }

-- Force no concealing - because I don't like concealing
vim.wo.conceallevel = 0

vim.opt.pumblend = 0

-- Disable all animations
vim.g.snacks_animate = false

vim.g.lazyvim_cmp = "nvim-cmp"

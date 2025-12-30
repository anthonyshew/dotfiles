-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.swapfile = false

vim.opt.wildignore = "**/node_modules/**"

-- Auto-reload files when changed externally
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None",
})

-- vim.api.nvim_create_user_command("Hey", function(opts)
--   -- local search_dirs = vim.split(opts.args, " ") -- Split args into a table
--   vim.api.nvim_command(string.format(":Telescope find_files search_dirs={'%s'}", opts.args))
--   -- vim.api.nvim_command(string.format(":Telescope find_files search_dirs={'~/.config/'}"))
--   -- vim.api.nvim_command(string.format(":Telescope find_files search_dirs={'%s'}", opts.args))
-- end, {})

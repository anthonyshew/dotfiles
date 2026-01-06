-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--

-- Quit all of neovim when :q is called in Neo-tree
vim.api.nvim_create_autocmd("FileType", {
  pattern = "neo-tree",
  callback = function()
    vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = true, desc = "Quit Neovim" })
    vim.keymap.set("c", "q<cr>", "qa<cr>", { buffer = true, desc = "Quit Neovim" })
  end,
})

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
local map = LazyVim.safe_keymap_set
local Path = require("plenary.path")

map({ "n" }, "<C-s>", ":silent write <Enter>")

-- quickfix list delete keymap
function Remove_qf_item()
  local curqfidx = vim.fn.line(".")
  local qfall = vim.fn.getqflist()

  -- Return if there are no items to remove
  if #qfall == 0 then
    return
  end

  -- Remove the item from the quickfix list
  table.remove(qfall, curqfidx)
  vim.fn.setqflist(qfall, "r")

  -- Reopen quickfix window to refresh the list
  vim.cmd("copen")

  -- If not at the end of the list, stay at the same index, otherwise, go one up.
  local new_idx = curqfidx < #qfall and curqfidx or math.max(curqfidx - 1, 1)

  -- Set the cursor position directly in the quickfix window
  local winid = vim.fn.win_getid() -- Get the window ID of the quickfix window
  vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
end

vim.cmd("command! RemoveQFItem lua Remove_qf_item()")
vim.api.nvim_command("autocmd FileType qf nnoremap <buffer> dd :RemoveQFItem<cr>")

--- Copy file path to clipboard

vim.api.nvim_create_user_command("CopyFilePathToClipboard", function()
  -- Get the current buffer's file path
  local file_path = vim.api.nvim_buf_get_name(0)

  -- Get the current working directory (project root)
  local current_dir = vim.fn.getcwd()

  -- Create a Path object for the current directory and get the parent directory
  local project_root = Path:new(current_dir):parent():absolute()

  -- Create a Path object for the file
  local path_obj = Path:new(file_path)

  -- Get the relative path from the project root
  local relative_path = path_obj:make_relative(project_root)

  local function removePrefix(str)
    -- Find the position of the first '/'
    local pos = string.find(str, "/", 1, true)

    if pos then
      -- If '/' is found, return the substring starting from the character after '/'
      return string.sub(str, pos + 1)
    else
      -- If no '/' is found, return the original string
      return str
    end
  end

  -- Copy the relative path to the system clipboard
  vim.fn.setreg("+", removePrefix(relative_path))
end, {})

vim.keymap.set("n", "<leader>cp", function()
  vim.cmd(":CopyFilePathToClipboard")
end, { desc = "Copy file path to clipboard" })

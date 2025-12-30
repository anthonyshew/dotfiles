local utils = require("fzf-lua").utils
local actions = require("fzf-lua").actions

local function hl_validate(hl)
  return not utils.is_hl_cleared(hl) and hl or nil
end

return {
  "ibhagwan/fzf-lua",
  keys = {
    {
      "<leader>gd",
      function()
        Snacks.terminal("critique main..HEAD", {
          win = {
            position = "float",
            width = 0,
            height = 0,
            border = "none",
            backdrop = false,
          },
        })
      end,
      desc = "Critique main..HEAD",
    },
  },
  opts = {
    { "default-title" }, -- base profile
    desc = "Match telescope default highlights/keybinds",
    fzf_opts = { ["--layout"] = "default", ["--marker"] = "+ ", ["--cycle"] = true },
    winopts = {
      width = 0.85,
      height = 0.9,
      preview = {
        hidden = false,
        vertical = "up:45%",
        horizontal = "right:50%",
        layout = "horizontal",
        flip_columns = 120,
        delay = 10,
        scrollbar = "float",
        winopts = { number = false },
      },
    },
    hls = {
      normal = hl_validate("TelescopeNormal"),
      border = hl_validate("TelescopeBorder"),
      title = hl_validate("TelescopePromptTitle"),
      help_normal = hl_validate("TelescopeNormal"),
      help_border = hl_validate("TelescopeBorder"),
      preview_normal = hl_validate("TelescopeNormal"),
      preview_border = hl_validate("TelescopeBorder"),
      preview_title = hl_validate("TelescopePreviewTitle"),
      -- builtin preview only
      cursor = hl_validate("Cursor"),
      cursorline = hl_validate("TelescopeSelection"),
      cursorlinenr = hl_validate("TelescopeSelection"),
      search = hl_validate("IncSearch"),
    },
    lsp = {
      jump_to_single_result = true,
      jump_to_single_result_action = actions.file_edit,
      header = string.format("You can just reference things."),
    },
    fzf_colors = {
      ["fg"] = { "fg", "TelescopeNormal" },
      ["bg"] = { "bg", "TelescopeNormal" },
      ["hl"] = { "fg", "TelescopeMatching" },
      ["fg+"] = { "fg", "TelescopeSelection" },
      ["bg+"] = { "bg", "TelescopeSelection" },
      ["hl+"] = { "fg", "TelescopeMatching" },
      ["info"] = { "fg", "TelescopeMultiSelection" },
      ["border"] = { "fg", "TelescopeBorder" },
      ["gutter"] = "-1",
      ["query"] = { "fg", "TelescopePromptNormal" },
      ["prompt"] = { "fg", "TelescopePromptPrefix" },
      ["pointer"] = { "fg", "TelescopeSelectionCaret" },
      ["marker"] = { "fg", "TelescopeSelectionCaret" },
      ["header"] = { "fg", "Comment" },
    },
    keymap = {
      builtin = {
        true,
        ["<C-d>"] = "preview-page-down",
        ["<C-u>"] = "preview-page-up",
      },
      fzf = {
        true,
        ["ctrl-d"] = "preview-page-down",
        ["ctrl-u"] = "preview-page-up",
        ["ctrl-q"] = "select-all+accept",
      },
    },
    actions = {
      files = {
        ["enter"] = actions.file_edit_or_qf,
        ["ctrl-x"] = actions.file_split,
        ["ctrl-v"] = actions.file_vsplit,
        ["ctrl-h"] = { actions.toggle_hidden },
        ["ctrl-i"] = { actions.toggle_ignore },
        ["ctrl-o"] = require("trouble.sources.fzf").actions.open,
      },
    },
    buffers = {
      keymap = { builtin = { ["<C-d>"] = false } },
      actions = { ["ctrl-x"] = false, ["ctrl-d"] = { actions.buf_del, actions.resume } },
      header = string.format("You can just buffer things."),
    },
    files = {
      header = string.format("You can just find things."),
    },
    grep = {
      header = string.format("You can just grep things."),
    },
    diagnostics = {
      header = string.format("You can just diagnostic things."),
    },
    marks = {
      header = string.format("You can just mark things."),
    },
    commits = {
      header = string.format("You can just commit things."),
    },
    status = {
      header = string.format("You can just status things."),
    },
    defaults = {
      git_icons = false,
      header = string.format("You can just fzf things."),
    },
  },
}

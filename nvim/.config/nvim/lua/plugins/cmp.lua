local cmp = require("cmp")

local lspkind_comparator = function(conf)
  local lsp_types = require("cmp.types").lsp
  return function(entry1, entry2)
    if entry1.source.name ~= "nvim_lsp" then
      if entry2.source.name == "nvim_lsp" then
        return false
      else
        return nil
      end
    end
    local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
    local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]

    local priority1 = conf.kind_priority[kind1] or 0
    local priority2 = conf.kind_priority[kind2] or 0
    if priority1 == priority2 then
      return nil
    end
    return priority2 < priority1
  end
end

local label_comparator = function(entry1, entry2)
  return entry1.completion_item.label < entry2.completion_item.label
end

return {
  "hrsh7th/nvim-cmp",
  opts = {
    window = {
      documentation = {
        border = "rounded",
      },
      completion = {
        border = "rounded",
      },
    },
    sources = {
      {
        name = "nvim_lsp",
        entry_filter = function(entry)
          return cmp.lsp.CompletionItemKind.Text ~= entry:get_kind()
            and cmp.lsp.CompletionItemKind.Snippet ~= entry:get_kind()
        end,
      },
      { name = "luasnip" },
    },
    preselect = cmp.PreselectMode.None,
    sorting = {
      comparators = {
        lspkind_comparator({
          kind_priority = {
            Field = 11,
            Property = 11,
            Constant = 10,
            Enum = 10,
            EnumMember = 10,
            Event = 10,
            Function = 10,
            Method = 10,
            Operator = 10,
            Reference = 10,
            Struct = 10,
            Variable = 9,
            File = 8,
            Folder = 8,
            Class = 5,
            Color = 5,
            Module = 5,
            Keyword = 2,
            Constructor = 1,
            Interface = 1,
            Snippet = 0,
            Text = 1,
            TypeParameter = 1,
            Unit = 1,
            Value = 1,
          },
        }),
        label_comparator,
      },
    },
  },
}

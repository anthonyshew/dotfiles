local function biome_lsp_or_prettier(bufnr)
  local has_biome = vim.fs.find({
    -- https://prettier.io/docs/en/configuration.html
    "biome.json",
    "biome.jsonc",
  }, { upward = true })[1]
  if has_biome then
    return { "biome" }
  end
  return { "prettier" }
end

return {
  -- Use Biome instead of prettier
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["javascript"] = biome_lsp_or_prettier,
        ["javascriptreact"] = biome_lsp_or_prettier,
        ["typescript"] = biome_lsp_or_prettier,
        ["typescriptreact"] = biome_lsp_or_prettier,
        ["json"] = biome_lsp_or_prettier,
        ["jsonc"] = biome_lsp_or_prettier,
        -- ["json"] = biome_lsp_or_prettier,
        -- ["jsonc"] = biome_lsp_or_prettier,
        -- Not supported by Biome
        ["vue"] = { "prettier" },
        ["css"] = biome_lsp_or_prettier,
        ["scss"] = { "prettier" },
        ["less"] = { "prettier" },
        ["html"] = { "prettier" },
        ["yaml"] = { "prettier" },
        ["markdown"] = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        ["graphql"] = { "prettier" },
        ["handlebars"] = { "prettier" },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "biome",
      },
    },
  },
}

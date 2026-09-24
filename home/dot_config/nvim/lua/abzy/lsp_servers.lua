vim.lsp.config['lua_ls'] = {
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

vim.lsp.config['clangd'] = {}

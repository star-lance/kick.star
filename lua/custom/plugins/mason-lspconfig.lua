-- Bridge between Mason and LSP config for automatic server setup
return {
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'ts_ls',                  -- TypeScript (was tsserver)
          'clangd',                 -- C/C++
          'kotlin_language_server', -- Kotlin
          'cssls',                  -- CSS
        },
        automatic_installation = false,
      }
    end,
  },
}

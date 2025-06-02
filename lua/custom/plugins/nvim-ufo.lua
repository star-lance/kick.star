-- Enhanced folding with treesitter support
return {
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      -- Set folding options
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

      -- Configure nvim-ufo
      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          return {'treesitter', 'indent'}
        end
      })

      -- Key mappings for folding
      local opts = { noremap = true, silent = true }
      
      -- Enhanced folding controls
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds, opts)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, opts)
      vim.keymap.set('n', 'zo', 'zo', opts)
      vim.keymap.set('n', 'zc', 'zc', opts)
      vim.keymap.set('n', 'za', 'za', opts)

      -- Quick peek at folded content
      vim.keymap.set('n', 'K', function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = 'Peek folded lines or LSP hover' })
    end,
  },
}

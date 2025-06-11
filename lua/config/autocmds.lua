-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Format Go files on save AND set tab display
vim.api.nvim_create_autocmd("FileType", {
  desc = 'Go file settings',
  pattern = "go",
  group = vim.api.nvim_create_augroup('go-settings', { clear = true }),
  callback = function()
    -- Smaller tab display
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2

    -- Format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = 0, -- Only for this buffer
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
})

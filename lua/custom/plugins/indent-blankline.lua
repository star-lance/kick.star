-- Adds indent guides and scope highlighting
return {
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup {
        indent = {
          char = '│',
        },
        scope = { enabled = true },
        exclude = {
          filetypes = {
            'help',
            'terminal',
            'dashboard',
            'packer',
            'lspinfo',
            'TelescopePrompt',
            'TelescopeResults',
          },
          buftypes = {
            'terminal',
            'nofile',
            'quickfix',
            'prompt',
          },
        },
      }
    end,
  },
}

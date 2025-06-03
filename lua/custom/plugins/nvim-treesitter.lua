return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'typescript', 'tsx', 'javascript', 'c', 'cpp', 'kotlin', 'lua', 'vim', 'vimdoc', 'query', 'css', 'scss', 'html',
          'hcl', 'terraform'
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = false,
        },
        incremental_selection = {
          enable = false,
          keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
          },
        },
        textobjects = {
          select = {
            enable = false,
          },
          move = {
            enable = false,
          },
        },
        autotag = {
          enable = false,
        },
        modules = {},
        ignore_install = {},
      }
    end,
  },
}

-- Highlights other instances of word under cursor
return {
  {
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure {
        providers = {
          'lsp',
          'treesitter',
          'regex',
        },
        delay = 100,
        filetype_overrides = {},
        filetypes_denylist = {
          'dirvish',
          'fugitive',
          'NvimTree',
          'neo-tree',
        },
        filetypes_allowlist = {},
        modes_denylist = {},
        modes_allowlist = {},
        providers_regex_syntax_denylist = {},
        providers_regex_syntax_allowlist = {},
        under_cursor = true,
        large_file_cutoff = 100000,
        large_file_overrides = nil,
        min_count_to_highlight = 1,
      }
    end,
  },
}

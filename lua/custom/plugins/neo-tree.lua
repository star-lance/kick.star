-- Modern file explorer with git status and diagnostics
return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        close_if_last_window = false,
        popup_border_style = 'rounded',
        enable_git_status = true,
        enable_diagnostics = true,
        default_component_configs = {
          indent = {
            with_markers = true,
            indent_marker = '│',
            last_indent_marker = '└',
            indent_size = 2,
          },
        },
        window = {
          width = 40,
          position = 'left',
        },
        filesystem = {
          follow_current_file = { enabled = false },
          use_libuv_file_watcher = true,
        },
      }
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { noremap = true, silent = true })
    end,
  },
}

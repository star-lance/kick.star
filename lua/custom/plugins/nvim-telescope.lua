return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-file-browser.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      require('telescope').setup {
        defaults = {
          prompt_prefix = ' ',
          selection_caret = ' ',
          path_display = { 'smart' },
          file_ignore_patterns = { '.git/', 'node_modules' },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
          file_browser = {
            theme = 'dropdown',
            hijack_netrw = true,
            mappings = {
              ['i'] = {
                ['<C-w>'] = function()
                  vim.cmd 'normal vbd'
                end,
              },
              ['n'] = {
                ['N'] = function()
                  vim.cmd 'normal a'
                end,
                ['h'] = function()
                  require('telescope').extensions.file_browser.actions.goto_parent_dir()
                end,
              },
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      }

      -- Load telescope extensions
      require('telescope').load_extension 'fzf'
      require('telescope').load_extension 'file_browser'
      require('telescope').load_extension 'ui-select'

      -- Key mappings
      vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = 'Live Grep' })
      vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = 'Buffers' })
      vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = 'Help Tags' })
      vim.keymap.set('n', '<leader>fs', require('telescope.builtin').grep_string, { desc = 'Grep String' })
      vim.keymap.set('n', '<leader>fo', require('telescope.builtin').oldfiles, { desc = 'Recent Files' })
      vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, { desc = 'Git Commits' })
      vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, { desc = 'Git Status' })
      vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { desc = 'LSP References' })
      vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = 'LSP Definitions' })
      vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations, { desc = 'LSP Implementations' })
      vim.keymap.set('n', '<leader>fd', function()
        require('telescope.builtin').diagnostics { bufnr = 0 }
      end, { desc = 'Document Diagnostics' })
      vim.keymap.set('n', '<leader>fD', require('telescope.builtin').diagnostics, { desc = 'Workspace Diagnostics' })
      vim.keymap.set('n', '<leader>fe', function()
        require('telescope').extensions.file_browser.file_browser()
      end, { desc = 'File Browser' })
    end,
  },
}

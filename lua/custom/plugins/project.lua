-- Project management with automatic directory switching
return {
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup {
        patterns = { '.git', 'Makefile', 'package.json' },
        detection_methods = { 'pattern', 'lsp' },
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = 'global',
        datapath = vim.fn.stdpath 'data',
      }

      -- Integrate with telescope
      require('telescope').load_extension 'projects'

      -- Add keymapping for projects
      vim.keymap.set('n', '<leader>fp', function()
        require('telescope').extensions.projects.projects {}
      end, { noremap = true, silent = true })
    end,
  },
}

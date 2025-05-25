-- Displays available keybindings in popup window
return {
  {
    'folke/which-key.nvim',
    config = function()
      vim.g.loaded_which_key_health = 1
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').setup {
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = false,
            suggestions = 20,
          },
          presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
          },
        },
        icons = {
          breadcrumb = '»',
          separator = '➜',
          group = '+',
        },
        keys = {
          scroll_down = '<c-d>',
          scroll_up = '<c-u>',
        },
        win = {
          border = 'rounded',
          position = 'bottom',
          margin = { 1, 0, 1, 0 },
          padding = { 2, 2, 2, 2 },
          winblend = 0,
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 20, max = 50 },
          spacing = 3,
          align = 'left',
        },
        filter = function(mode, buf, key)
          return false
        end,
        show_help = true,
        show_keys = true,
        triggers = { "<leader>" },
        disable = {
          buftypes = {},
          filetypes = { 'TelescopePrompt' },
        },
      }

      -- Register key groups
      local wk = require 'which-key'
      wk.add {
        { '<leader>d', group = 'Debug' },
        { '<leader>f', group = 'Find' },
        { '<leader>g', group = 'Git' },
        { '<leader>h', group = 'Hunks' },
        { '<leader>x', group = 'Trouble' },
      }
    end,
  },
}

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-telescope/telescope-dap.nvim',
      'mxsdev/nvim-dap-vscode-js',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- DAP UI setup
      dapui.setup()

      -- DAP Virtual Text setup (MODIFIED: enabled)
      require('nvim-dap-virtual-text').setup {
        enabled = true,
        highlight_changed_variables = true,
        show_stop_reason = true,
      }

      -- Telescope DAP extensions
      require('telescope').load_extension 'dap'

      -- Configure language adapters
      -- For TypeScript (MODIFIED: fixed debugger_path)
      require('dap-vscode-js').setup {
        adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
        node_path = "node",
        debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter", -- Fixed path
        debugger_cmd = { "js-debug-adapter" },
        log_file_path = vim.fn.stdpath("cache") .. "/dap_vscode_js.log",
        log_file_level = vim.log.levels.ERROR,
        log_console_level = vim.log.levels.ERROR,
      }

      -- ADDED: Language configurations for React/TypeScript
      for _, language in ipairs({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }) do
        dap.configurations[language] = {
          -- Debug Vite dev server
          {
            type = 'pwa-chrome',
            request = 'launch',
            name = 'Debug Vite App',
            url = 'http://localhost:5173',
            webRoot = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**' },
          },
          -- Debug current file in Node
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Debug Current File (Node)',
            program = '${file}',
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**' },
          },
        }
      end

      -- C/C++ adapter
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = 'gdb',
      }

      -- ADDED: Breakpoint signs
      vim.fn.sign_define('DapBreakpoint', { text = '🟥', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '🟨', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '🟦', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '🟪', texthl = '', linehl = '', numhl = '' })

      -- Basic keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Continue' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Conditional Breakpoint' })
      vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Debug: Open REPL' })
      vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug: Run Last' })

      -- ADDED: Additional useful keymaps
      vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = 'Debug: Terminate' })
      vim.keymap.set('n', '<leader>dc', dap.clear_breakpoints, { desc = 'Debug: Clear Breakpoints' })
      vim.keymap.set('n', '<leader>de', function() require('dapui').eval() end, { desc = 'Debug: Evaluate Expression' })

      -- ADDED: Telescope DAP commands
      vim.keymap.set('n', '<leader>dC', '<cmd>Telescope dap commands<cr>', { desc = 'Debug: Commands' })
      vim.keymap.set('n', '<leader>df', '<cmd>Telescope dap frames<cr>', { desc = 'Debug: Frames' })
      vim.keymap.set('n', '<leader>dv', '<cmd>Telescope dap variables<cr>', { desc = 'Debug: Variables' })

      -- Toggle DAP UI
      vim.keymap.set('n', '<leader>du', function()
        dapui.toggle()
      end, { desc = 'Debug: Toggle UI' })

      -- Automatically open/close DAP UI when debugging session starts/ends
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },
}

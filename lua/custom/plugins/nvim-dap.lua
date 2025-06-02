-- CORRECT Firefox debugging setup for Neovim
return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-telescope/telescope-dap.nvim',
    },
    config = function()
      require('dap').set_log_level('TRACE')
      local dap = require 'dap'
      local dapui = require 'dapui'
      local function start_firefox_debug()
        -- Start Firefox debug server automatically
        vim.fn.system("firefox-debug")
        vim.cmd("sleep 2000m") -- Wait 2 seconds
      end


      -- Firefox Debug Adapter (install via Mason: firefox-debug-adapter)
      dap.adapters.firefox = {
        type = 'executable',
        command = 'node',
        args = {
          vim.fn.stdpath("data") .. "/mason/packages/firefox-debug-adapter/dist/adapter.bundle.js"
        },
      }

      -- Alternative: Node.js debugging with vscode-js-debug (if you also want Node.js debugging)
      dap.adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            '${port}'
          },
        }
      }

      -- Configure for all JS/TS file types
      for _, language in ipairs({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }) do
        dap.configurations[language] = {
          -- Firefox debugging configuration
          {
            name = 'Debug with Firefox',
            type = 'firefox',
            request = 'launch',
            reAttach = true,
            url = 'http://localhost:5173',
            webRoot = '${workspaceFolder}',
            url = 'http://localhost:5173',
            firefoxExecutable = '/usr/bin/firefox', -- Adjust path if needed
            -- Optional: increase timeout if Firefox is slow to start
            timeout = 30000,
            -- Optional: specify profile directory
            -- profileDir = '/tmp/nvim-dap-firefox-profile',
          },

          -- Attach to running Firefox (manual start required)
          {
            name = 'Attach to Firefox',
            type = 'firefox',
            request = 'attach',
            webRoot = '${workspaceFolder}',
            url = 'http://localhost:5173',
            -- Firefox must be started manually with: firefox -start-debugger-server=6000
            port = 6000,
          },

          -- Node.js debugging (for server-side code)
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Debug Current File (Node)',
            program = '${file}',
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**' },
          },
          {
            name = 'Auto-start Firefox Debug',
            type = 'firefox',
            request = 'attach',
            webRoot = '${workspaceFolder}',
            url = 'http://localhost:5173',
            port = 6000,
            preLaunchTask = function()
              start_firefox_debug()
            end,
          }
        }
      end

      -- Simple DAP UI setup
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.4 },
              { id = "breakpoints", size = 0.3 },
              { id = "stacks",      size = 0.3 }
            },
            position = "left",
            size = 40
          },
          {
            elements = {
              { id = "repl",    size = 0.7 },
              { id = "console", size = 0.3 }
            },
            position = "bottom",
            size = 10
          }
        },
      })
      vim.api.nvim_create_user_command('FirefoxDebugStart', function()
        vim.fn.system("firefox-debug")
        print("Firefox debug server starting...")
      end, {})

      vim.api.nvim_create_user_command('FirefoxDebugStop', function()
        vim.fn.system("firefox-debug-kill")
        print("Firefox debug server stopped")
      end, {})

      require('nvim-dap-virtual-text').setup()

      -- Telescope extension
      require('telescope').load_extension 'dap'

      -- Breakpoint signs
      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', linehl = 'DapStoppedLine' })

      -- Highlight groups
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4057' })

      -- Essential debug keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = 'Debug: Terminate' })
      vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })

      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },
}

-- Debug Adapter Protocol client for debugging support with Firefox
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
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- DAP UI setup
      dapui.setup({
        controls = {
          element = "repl",
          enabled = true,
          icons = {
            disconnect = "",
            pause = "",
            play = "",
            run_last = "",
            step_back = "",
            step_into = "",
            step_out = "",
            step_over = "",
            terminate = ""
          }
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" }
          }
        },
        force_buffers = true,
        icons = {
          collapsed = "",
          current_frame = "",
          expanded = ""
        },
        layouts = {
          {
            elements = {
              {
                id = "scopes",
                size = 0.25
              },
              {
                id = "breakpoints",
                size = 0.25
              },
              {
                id = "stacks",
                size = 0.25
              },
              {
                id = "watches",
                size = 0.25
              }
            },
            position = "left",
            size = 40
          },
          {
            elements = {
              {
                id = "repl",
                size = 0.5
              },
              {
                id = "console",
                size = 0.5
              }
            },
            position = "bottom",
            size = 10
          }
        },
        mappings = {
          edit = "e",
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "t"
        },
        render = {
          indent = 1,
          max_value_lines = 100
        }
      })

      -- DAP Virtual Text setup
      require('nvim-dap-virtual-text').setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
      }

      -- Telescope DAP extensions
      require('telescope').load_extension 'dap'

      -- Configure DAP adapters for Node.js debugging
      dap.adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug-adapter",
          args = { '${port}' },
        }
      }

      -- Configure DAP adapters for Firefox debugging
      dap.adapters['pwa-firefox'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug-adapter",
          args = { '${port}' },
        }
      }

      -- Helper function to detect Firefox executable
      local function get_firefox_executable()
        local possible_paths = {
          '/usr/bin/firefox',
          '/usr/bin/firefox-developer-edition',
          '/usr/bin/firefox-nightly',
          '/opt/firefox/firefox',
          '/snap/bin/firefox',
        }
        
        for _, path in ipairs(possible_paths) do
          if vim.fn.executable(path) == 1 then
            return path
          end
        end
        
        -- Fallback to system PATH
        if vim.fn.executable('firefox') == 1 then
          return 'firefox'
        end
        
        return '/usr/bin/firefox' -- Default assumption
      end

      -- Language configurations for React/TypeScript with Firefox
      for _, language in ipairs({ 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }) do
        dap.configurations[language] = {
          -- Debug Vite dev server with Firefox
          {
            type = 'pwa-firefox',
            request = 'launch',
            name = 'Debug Vite App (Firefox)',
            url = 'http://localhost:5173',
            webRoot = '${workspaceFolder}',
            protocol = 'inspector',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**' },
            firefoxExecutable = get_firefox_executable(),
            profileDir = '/tmp/nvim-dap-firefox-profile',
            keepProfileChanges = false,
            preferences = {
              ['devtools.debugger.remote-enabled'] = true,
              ['devtools.chrome.enabled'] = true,
              ['devtools.debugger.workers'] = true,
              ['devtools.debugger.prompt-connection'] = false,
              ['devtools.debugger.force-local'] = true,
              ['dom.webnotifications.enabled'] = false,
              ['media.navigator.permission.disabled'] = true,
            },
            pathMappings = {
              {
                url = 'http://localhost:5173',
                path = '${workspaceFolder}',
              }
            },
          },
          -- Debug Vite app with custom port
          {
            type = 'pwa-firefox',
            request = 'launch',
            name = 'Debug Vite App (Custom Port)',
            url = function()
              local port = vim.fn.input('Port: ', '5173')
              return 'http://localhost:' .. port
            end,
            webRoot = '${workspaceFolder}',
            protocol = 'inspector',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**' },
            firefoxExecutable = get_firefox_executable(),
            profileDir = '/tmp/nvim-dap-firefox-profile',
            keepProfileChanges = false,
            preferences = {
              ['devtools.debugger.remote-enabled'] = true,
              ['devtools.chrome.enabled'] = true,
              ['devtools.debugger.workers'] = true,
              ['devtools.debugger.prompt-connection'] = false,
              ['devtools.debugger.force-local'] = true,
              ['dom.webnotifications.enabled'] = false,
              ['media.navigator.permission.disabled'] = true,
            },
          },
          -- Debug current TypeScript/JavaScript file in Node
          {
            type = 'pwa-node',
            request = 'launch', 
            name = 'Debug Current File (Node)',
            program = '${file}',
            cwd = '${workspaceFolder}',
            protocol = 'inspector',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**' },
            resolveSourceMapLocations = {
              '${workspaceFolder}/**',
              '!**/node_modules/**'
            },
          },
          -- Debug Jest tests
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Debug Jest Tests',
            cwd = '${workspaceFolder}',
            runtimeArgs = { '--inspect-brk', '${workspaceFolder}/node_modules/.bin/jest', '--no-coverage', '--no-cache' },
            runtimeExecutable = 'node',
            skipFiles = { '<node_internals>/**', '**/node_modules/**' },
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
            disableOptimisticBPs = true,
            windows = {
              runtimeArgs = { '--inspect-brk', '${workspaceFolder}/node_modules/jest/bin/jest.js', '--no-coverage', '--no-cache' },
            }
          },
          -- Attach to running Node process
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach to Node Process',
            processId = require'dap.utils'.pick_process,
            cwd = '${workspaceFolder}',
            protocol = 'inspector',
            skipFiles = { '<node_internals>/**' },
          },
        }
      end

      -- C/C++ debugging configuration
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = vim.fn.stdpath("data") .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
      }

      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = true,
        },
        {
          name = 'Attach to gdbserver :1234',
          type = 'cppdbg',
          request = 'launch',
          MIMode = 'gdb',
          miDebuggerServerAddress = 'localhost:1234',
          miDebuggerPath = '/usr/bin/gdb',
          cwd = '${workspaceFolder}',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
        },
      }

      dap.configurations.c = dap.configurations.cpp

      -- Kotlin debugging (if needed)
      dap.adapters.kotlin = {
        type = 'executable',
        command = 'kotlin-debug-adapter',
        options = { auto_continue_if_many_stopped = false },
      }

      -- Configure breakpoint signs
      vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '🟡', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '🔵', texthl = 'DapLogPoint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '▶️', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '🚫', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })

      -- Define highlight groups
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#f1c40f' })
      vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4057' })
      vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#8b0000' })

      -- Essential debug keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Continue' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Conditional Breakpoint' })

      -- Additional debug keymaps
      vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Debug: Open REPL' })
      vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug: Run Last' })
      vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = 'Debug: Terminate' })
      vim.keymap.set('n', '<leader>dc', dap.clear_breakpoints, { desc = 'Debug: Clear Breakpoints' })
      vim.keymap.set('n', '<leader>de', function() 
        require('dapui').eval(nil, { enter = true })
      end, { desc = 'Debug: Evaluate Expression' })

      -- Telescope DAP commands
      vim.keymap.set('n', '<leader>dC', '<cmd>Telescope dap commands<cr>', { desc = 'Debug: Commands' })
      vim.keymap.set('n', '<leader>df', '<cmd>Telescope dap frames<cr>', { desc = 'Debug: Frames' })
      vim.keymap.set('n', '<leader>dv', '<cmd>Telescope dap variables<cr>', { desc = 'Debug: Variables' })
      vim.keymap.set('n', '<leader>db', '<cmd>Telescope dap list_breakpoints<cr>', { desc = 'Debug: List Breakpoints' })

      -- Toggle DAP UI
      vim.keymap.set('n', '<leader>du', function()
        dapui.toggle()
      end, { desc = 'Debug: Toggle UI' })

      -- DAP UI specific keymaps
      vim.keymap.set('n', '<leader>dh', function()
        require('dap.ui.widgets').hover()
      end, { desc = 'Debug: Hover Variables' })

      vim.keymap.set('n', '<leader>dp', function()
        require('dap.ui.widgets').preview()
      end, { desc = 'Debug: Preview' })

      vim.keymap.set('n', '<leader>ds', function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.scopes)
      end, { desc = 'Debug: Scopes' })

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

      -- Auto-create profile directory for Firefox
      vim.api.nvim_create_autocmd('User', {
        pattern = 'DapSessionStarted',
        callback = function()
          local profile_dir = '/tmp/nvim-dap-firefox-profile'
          if vim.fn.isdirectory(profile_dir) == 0 then
            vim.fn.mkdir(profile_dir, 'p')
          end
        end,
      })

      -- Clean up Firefox profile on exit
      vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = function()
          local profile_dir = '/tmp/nvim-dap-firefox-profile'
          if vim.fn.isdirectory(profile_dir) == 1 then
            vim.fn.system('rm -rf ' .. profile_dir)
          end
        end,
      })
    end,
  },
}

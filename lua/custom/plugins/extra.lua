-- Complete lazy.nvim configuration for IDE features
-- Add this to your existing kickstart.nvim config
-- Skip specific health checks
vim.g.loaded_which_key_health = 1
return {
  -- LSP Configuration
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'tsserver', -- TypeScript
          'clangd', -- C/C++
          'kotlin_language_server', -- Kotlin
        },
        automatic_installation = false,
      }
    end,
  },

  -- GitHub Copilot
  {
    'github/copilot.vim',
    config = function()
      -- Default configuration
      vim.g.copilot_enabled = true
      -- Tab is default for accepting suggestions
      -- No need to change default mappings
    end,
  },

  -- File Explorer (Neo-tree)
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
          follow_current_file = false,
          use_libuv_file_watcher = true,
        },
      }
      -- You'll need to add a mapping for toggling neo-tree
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { noremap = true, silent = true })
    end,
  },

  -- Debugging with DAP
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio', -- Required dependency for nvim-dap-ui
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-telescope/telescope-dap.nvim',
      'mxsdev/nvim-dap-vscode-js', -- For TypeScript
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- DAP UI setup
      dapui.setup()

      -- DAP Virtual Text setup
      require('nvim-dap-virtual-text').setup {
        enabled = false, -- Default is false
      }

      -- Telescope DAP extensions
      require('telescope').load_extension 'dap'

      -- Configure language adapters
      -- For TypeScript
      require('dap-vscode-js').setup {
        adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
      }

      -- C/C++ adapter
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = 'gdb', -- Changed from lldb-vscode to gdb, which is more commonly installed
      }

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

  -- Enhanced Code Completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'onsails/lspkind.nvim', -- Icons in completion menu
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true },

          -- Make Tab work with Copilot
          ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end,
          ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
        },
        sources = cmp.config.sources {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol_text',
            maxwidth = 50,
            ellipsis_char = '...',
          },
        },
      }

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
      })
    end,
  },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {},
      }
    end,
  },

  -- Terminal Integration
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        size = function(term)
          if term.direction == 'horizontal' then
            return 12
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]], -- Adding a mapping since it's essential
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = 'horizontal',
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = 'curved',
          winblend = 0,
          highlights = {
            border = 'Normal',
            background = 'Normal',
          },
        },
      }
    end,
  },

  -- Git Integration
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          follow_files = true,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1,
        },
        yadm = {
          enable = false,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          vim.keymap.set('n', ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, buffer = bufnr })

          vim.keymap.set('n', '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, buffer = bufnr })

          -- Mappings
          vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr })
          vim.keymap.set('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { buffer = bufnr })
          vim.keymap.set('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hb', function()
            gs.blame_line { full = true }
          end, { buffer = bufnr })
          vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hD', function()
            gs.diffthis '~'
          end, { buffer = bufnr })
          vim.keymap.set('n', '<leader>td', gs.toggle_deleted, { buffer = bufnr })
        end,
      }
    end,
  },

  -- Trouble (Diagnostics, References, etc.)
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('trouble').setup {
        position = 'bottom',
        height = 10,
        width = 50,
        icons = true,
        mode = 'workspace_diagnostics',
        fold_open = '',
        fold_closed = '',
        group = true,
        padding = true,
        action_keys = {
          close = 'q',
          cancel = '<esc>',
          refresh = 'r',
          jump = { '<cr>', '<tab>' },
          open_split = { '<c-x>' },
          open_vsplit = { '<c-v>' },
          open_tab = { '<c-t>' },
          jump_close = { 'o' },
          toggle_mode = 'm',
          toggle_preview = 'P',
          hover = 'K',
          preview = 'p',
          close_folds = { 'zM', 'zm' },
          open_folds = { 'zR', 'zr' },
          toggle_fold = { 'zA', 'za' },
          previous = 'k',
          next = 'j',
        },
        indent_lines = true,
        auto_open = false,
        auto_close = false,
        auto_preview = true,
        auto_fold = false,
        auto_jump = { 'lsp_definitions' },
        signs = {
          error = '',
          warning = '',
          hint = '',
          information = '',
          other = '',
        },
        use_diagnostic_signs = false,
      }

      -- Add keybinding to toggle Trouble
      vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle<cr>', { silent = true, noremap = true })
      vim.keymap.set('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', { silent = true, noremap = true })
      vim.keymap.set('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', { silent = true, noremap = true })
      vim.keymap.set('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', { silent = true, noremap = true })
      vim.keymap.set('n', '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', { silent = true, noremap = true })
      vim.keymap.set('n', 'gR', '<cmd>TroubleToggle lsp_references<cr>', { silent = true, noremap = true })
    end,
  },

  -- Project Management
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

  -- Enhanced Syntax with Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag', -- Auto close HTML/JSX tags
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'typescript', 'tsx', 'javascript', 'c', 'cpp', 'kotlin', 'lua', 'vim', 'vimdoc', 'query' },
        sync_install = false,
        auto_install = false,
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
      }
    end,
  },

  -- Code Formatting and Linting
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          typescript = { 'prettier' },
          javascript = { 'prettier' },
          typescriptreact = { 'prettier' },
          javascriptreact = { 'prettier' },
          json = { 'prettier' },
          html = { 'prettier' },
          css = { 'prettier' },
          scss = { 'prettier' },
          c = { 'clang-format' },
          cpp = { 'clang-format' },
          kotlin = { 'ktlint' },
        },
        format_on_save = false,
        format_timeout = 500, -- milliseconds
      }

      -- Add keybinding for formatting
      vim.keymap.set('n', '<leader>f', function()
        require('conform').format()
      end, { noremap = true, silent = true })
    end,
  },

  -- Code Navigation and Search
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-file-browser.nvim',
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
                -- Correct action mappings for file browser
                ['N'] = function()
                  vim.cmd 'normal a'
                end, -- Just enter insert mode as a replacement
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
  {
    'folke/which-key.nvim',
    config = function()
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
          return false -- Don't filter anything
        end,

        show_help = true,
        show_keys = true,

        -- For triggers, use "auto" or a single string element
       triggers = { "<leader>" },

        disable = {
          buftypes = {},
          filetypes = { 'TelescopePrompt' },
        },
      }

      -- Register key groups with the new array-based format
      local wk = require 'which-key'
      wk.add{
        { '<leader>d', group = 'Debug' },
        { '<leader>f', group = 'Find' },
        { '<leader>g', group = 'Git' },
        { '<leader>h', group = 'Hunks' },
        { '<leader>x', group = 'Trouble' },
      }
    end,
  },
  -- Additional Quality of Life Plugins

  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {
        check_ts = true,
        ts_config = {
          lua = { 'string' },
          javascript = { 'template_string' },
          java = false,
        },
        disable_filetype = { 'TelescopePrompt' },
        fast_wrap = {
          map = '<M-e>',
          chars = { '{', '[', '(', '"', "'" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
          offset = 0,
          end_key = '$',
          keys = 'qwertyuiopzxcvbnmasdfghjkl',
          check_comma = true,
          highlight = 'PmenuSel',
          highlight_grey = 'LineNr',
        },
      }

      -- Make it work with cmp
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup {
        padding = true,
        sticky = true,
        ignore = nil,
        toggler = {
          line = 'gcc',
          block = 'gbc',
        },
        opleader = {
          line = 'gc',
          block = 'gb',
        },
        extra = {
          above = 'gcO',
          below = 'gco',
          eol = 'gcA',
        },
        mappings = {
          basic = true,
          extra = true,
        },
        pre_hook = nil,
        post_hook = nil,
      }
    end,
  },
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
  {
    'j-hui/fidget.nvim',
    tag = 'legacy',
    config = function()
      require('fidget').setup {
        text = {
          spinner = 'pipe',
          done = '✓',
          commenced = 'Started',
          completed = 'Completed',
        },
        align = {
          bottom = true,
          right = true,
        },
        timer = {
          spinner_rate = 125,
          fidget_decay = 2000,
          task_decay = 1000,
        },
        window = {
          relative = 'win',
          blend = 100,
          zindex = nil,
          border = 'none',
        },
        fmt = {
          leftpad = true,
          stack_upwards = true,
          max_width = 0,
          fidget = function(fidget_name, spinner)
            return string.format('%s %s', spinner, fidget_name)
          end,
          task = function(task_name, message, percentage)
            return string.format('%s%s [%s]', message, percentage and string.format(' (%s%%)', percentage) or '', task_name)
          end,
        },
        sources = {},
        debug = {
          logging = false,
          strict = false,
        },
      }
    end,
  },
}

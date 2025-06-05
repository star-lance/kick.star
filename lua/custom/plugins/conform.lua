-- Code formatting plugin with support for multiple formatters
return {
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          typescript = { 'prettier' },
          javascript = { 'prettier' },
          typescriptreact = { 'prettier' },
          javascriptreact = { 'prettier' },
          ['typescript.tsx'] = { 'prettier' },
          ['javascript.jsx'] = { 'prettier' },
          json = { 'prettier' },
          html = { 'prettier' },
          css = { 'prettier' },
          scss = { 'prettier' },
          c = { 'clang-format' },
          cpp = { 'clang-format' },
          kotlin = { 'ktlint' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters = {
          prettier = {
            command = function()
              local pnpm_prefix = vim.fn.trim(vim.fn.system("pnpm config get prefix"))
              local pnpm_prettier = pnpm_prefix .. "/node_modules/.bin/prettier"

              if vim.fn.filereadable(pnpm_prettier) == 1 then
                return pnpm_prettier
              end

              if vim.fn.executable("prettier") == 1 then
                return "prettier"
              end

              if vim.fn.glob(vim.fn.stdpath("data") .. "/mason/bin/prettier") ~= "" then
                return vim.fn.stdpath("data") .. "/mason/bin/prettier"
              end

              return nil
            end,
            -- No hardcoded style preferences - let projects decide
            args = { "--stdin-filepath", "$FILENAME" },
            range_args = function(ctx)
              return { "--stdin-filepath", "$FILENAME", "--range-start", ctx.range.start, "--range-end", ctx.range
                  ["end"] }
            end,
          },
        },
        format_timeout = 500,
      }

      -- Add keybinding for formatting with better error handling
      vim.keymap.set("n", "<leader>f", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local conform = require("conform")

        if not conform.can_format_buffer(bufnr) then
          local filetype = vim.bo.filetype
          vim.notify("No conform formatter available for filetype: " .. filetype .. ". Trying LSP formatter...",
            vim.log.levels.WARN)

          if vim.lsp.buf.format then
            vim.lsp.buf.format({
              async = true,
              bufnr = bufnr,
            })
            return
          else
            vim.notify("LSP formatter also not available", vim.log.levels.ERROR)
            return
          end
        end

        conform.format({
          bufnr = bufnr,
          async = true,
          lsp_fallback = true,
          callback = function(err)
            if err then
              vim.notify("Error formatting: " .. err, vim.log.levels.ERROR)
            end
          end
        })
      end, { noremap = true, desc = "Format buffer" })
    end,
  },
}

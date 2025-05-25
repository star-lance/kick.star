-- Package manager for LSP servers, formatters, and linters
return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()

      -- Ensure formatters are installed
      local ensure_installed = {
        "prettier",     -- For TypeScript/JavaScript/TSX/JSX
        "clang-format", -- For C/C++
        "ktlint",       -- For Kotlin
      }

      -- Check if mason-registry module exists and install formatters
      local has_mason_registry, mason_registry = pcall(require, "mason-registry")
      if has_mason_registry then
        for _, formatter in ipairs(ensure_installed) do
          if not mason_registry.is_installed(formatter) then
            vim.cmd("MasonInstall " .. formatter)
          end
        end
      end
    end,
  },
}

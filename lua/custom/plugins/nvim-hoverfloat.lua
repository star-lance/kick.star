return {
  {
    -- Use GitHub version
    "star-lance/nvim-hoverfloat",
    build = "make install", -- Essential: builds the TUI binary
    config = function()
      require("hoverfloat").setup({
        tui = {
          terminal_cmd = "kitty",
        },
        communication = {
          update_delay = 50, -- Moved to correct location
        },
        auto_start = true,   -- Start automatically
      })
    end,
    -- Load for relevant filetypes including TSX
    ft = {
      "lua", "python", "javascript", "typescript",
      "typescriptreact", "javascriptreact", -- TSX/JSX support
      "rust", "go", "c", "cpp", "java"
    },
    -- Or use this instead of ft to load after LSP attaches
    -- event = "LspAttach",
  }
}

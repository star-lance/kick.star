local use_local = false -- Set to false to use GitHub version

return {
  use_local and {
    dir = "/home/star/code/nvim-plugins/nvim-hoverfloat",
    build = "make install", -- Essential: builds the TUI binary
    config = function()
      require("hoverfloat").setup({
        tui = {
          terminal_cmd = "kitty",
        },
        communication = {
          update_delay = 50,
        },
        auto_start = true,
      })
    end,
    -- Load for relevant filetypes including TSX
    ft = {
      "lua", "python", "javascript", "typescript",
      "typescriptreact", "javascriptreact",
      "rust", "go", "c", "cpp", "java"
    },
    -- Or use this instead of ft to load after LSP attaches
    -- event = "LspAttach",
  } or {
    "star-lance/nvim-hoverfloat",
    build = "make install",
    config = function()
      require("hoverfloat").setup({
        tui = {
          terminal_cmd = "kitty",
        },
        communication = {
          update_delay = 50,
          debug = true, -- Enable debug output
        },
        auto_start = true,
      })
    end,
    ft = {
      "lua", "python", "javascript", "typescript",
      "typescriptreact", "javascriptreact",
      "rust", "go", "c", "cpp", "java"
    },
  }
}

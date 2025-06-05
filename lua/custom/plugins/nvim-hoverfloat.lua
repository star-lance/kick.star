return {
  "star-lance/nvim-hoverfloat",
  config = function()
    require("hoverfloat").setup({
      terminal_cmd = "kitty", -- or your preferred terminal
      update_delay = 50,
    })
  end,
}

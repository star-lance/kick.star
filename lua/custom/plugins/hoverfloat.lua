return {
  {
    "star-lance/nvim-hoverfloat",
    build = "make install-dev",
    config = function()
      require("hoverfloat").setup()
    end,
    ft = { "lua", "python", "javascript", "typescript", "rust", "go" },
  }
}

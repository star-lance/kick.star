-- Collection of minimal Neovim plugins (using surround module)
return {
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Mini.surround for surrounding text objects
      require('mini.surround').setup()
    end,
  },
}

-- Highlights and manages TODO, FIXME, and other comment keywords
return {
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('todo-comments').setup {}
    end,
  },
}

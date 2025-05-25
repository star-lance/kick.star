-- Smart commenting plugin with motion and visual mode support
return {
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
        pre_hook = function() return nil end,
        post_hook = function() return nil end,
      }
    end,
  },
}

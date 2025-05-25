-- Highlights color codes and color names in various formats
return {
  {
    'norcalli/nvim-colorizer.lua',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('colorizer').setup({
        -- Enable for all filetypes
        '*',
        -- Customize specific filetypes
        css = { rgb_fn = true, hsl_fn = true },
        html = { mode = 'foreground' },
        -- Exclude some filetypes if needed
        -- '!vim',
      }, {
        -- Default options (applied to all filetypes)
        RGB = true,          -- #RGB hex codes
        RRGGBB = true,       -- #RRGGBB hex codes
        names = true,        -- "Name" codes like Blue
        RRGGBBAA = true,     -- #RRGGBBAA hex codes
        rgb_fn = false,      -- CSS rgb() and rgba() functions
        hsl_fn = false,      -- CSS hsl() and hsla() functions
        css = false,         -- Enable all CSS features
        css_fn = false,      -- Enable all CSS functions
        mode = 'background', -- Set the display mode
      })
    end,
  },
}

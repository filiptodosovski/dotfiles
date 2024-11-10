return {
  'mvllow/modes.nvim',
  tag = 'v0.2.0',
  config = function ()
    require('modes').setup({
      set_cursor = false
    })
  end
}

return {
  "m4xshen/autoclose.nvim",
  config = function ()
    require("autoclose").setup({
      ['"'] = { escape = false, close = false, pair = '""' },
      ["'"] = { escape = false, close = false, pair = "''" },
      ["`"] = { escape = false, close = false, pair = "``" },
      options = {
      disabled_filetypes = { "text", "markdown" },
      },
    })
  end
}

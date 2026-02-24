return {
  'nvim-treesitter/nvim-treesitter-context',
  event = { "BufReadPost", "BufNewFile" },
  config = function ()

    require'treesitter-context'.setup{
      enable = true,
      max_lines = 3,
      line_numbers = true
    }
  end
}

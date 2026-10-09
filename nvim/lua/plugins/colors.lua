return {
  "rose-pine/neovim",
  name = "rose-pine",
  config = function()
    require("rose-pine").setup({
      variant = "main",
      dark_variant = "main",
      highlight_groups = {
        Normal = { bg = "NONE" },
        NormalFloat = { bg = "NONE" },
      },
    })
    vim.cmd("colorscheme rose-pine")
  end,
}

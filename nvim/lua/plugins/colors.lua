return {
  "rose-pine/neovim",
  name = "rose-pine",
  config = function()
    require("rose-pine").setup({
      variant = "main",
      dark_variant = "main",
      disable_background = true,
    })
    vim.cmd("colorscheme rose-pine")

    -- Keep Neovim transparent so the WezTerm background remains visible.
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  end,
}

require("fit0.set")
require("fit0.remap")

local autocmd = vim.api.nvim_create_autocmd
local yank_group = vim.api.nvim_create_augroup("HighlightYank", { clear = true })

autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.hl.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

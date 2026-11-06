require("fit0.set")
require("fit0.remap")

local autocmd = vim.api.nvim_create_autocmd
local yank_group = vim.api.nvim_create_augroup("HighlightYank", { clear = true })

-- Netrw can leave an empty startup placeholder beside an unnamed directory listing.
autocmd("VimEnter", {
  once = true,
  callback = vim.schedule_wrap(function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo.filetype == "netrw" and vim.api.nvim_buf_get_name(buf) == "" then
      local path = vim.b.netrw_curdir
      if not path or path == "" then
        return
      end
      local placeholder = vim.fn.bufnr(path)
      if
        placeholder > 0
        and vim.bo[placeholder].filetype == ""
        and not vim.bo[placeholder].modified
      then
        vim.cmd.bwipeout(placeholder)
      end
      vim.api.nvim_buf_set_name(buf, path)
    end
  end),
})

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

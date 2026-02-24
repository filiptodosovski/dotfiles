return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    { "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
    { "gr", "<cmd>Trouble lsp_references toggle<cr>", desc = "References" },
  },
  opts = {},
}

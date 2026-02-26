return {
  "vim-test/vim-test",
  cmd = { "TestNearest", "TestFile", "TestLast", "TestVisit" },
  keys = {
    { "<leader>tn", "<cmd>TestNearest<CR>", desc = "Test Nearest" },
    { "<leader>tf", "<cmd>TestFile<CR>", desc = "Test File" },
    { "<leader>tl", "<cmd>TestLast<CR>", desc = "Test Last" },
    { "<leader>tv", "<cmd>TestVisit<CR>", desc = "Test Visit" },
  },
  config = function()
    vim.g["test#strategy"] = "neovim"
    vim.g["test#neovim#term_position"] = "botright 12split"
  end,
}

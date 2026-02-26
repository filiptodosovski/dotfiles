return {
    { "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require('gitsigns')
      gitsigns.setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 200
        }
      })

      vim.keymap.set('n', "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
      vim.keymap.set('n', "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
    end
  },
  {
    'akinsho/git-conflict.nvim',
    version = "*",
    config = true
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      { "<leader>gc", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit Current File" },
      { "<leader>gf", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit Filter Current File" },
    }
  }
}

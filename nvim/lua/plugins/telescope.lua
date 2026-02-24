return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  cmd = "Telescope",
  -- or                            , branch = '0.1.x',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    {
      "isak102/telescope-git-file-history.nvim",
      dependencies = { "tpope/vim-fugitive" }
    }
  },
  keys = {
    { '<leader>pf', "<cmd>Telescope git_files<CR>" },
    { '<leader>ff', "<cmd>Telescope find_files<CR>", desc = "Find Files" },
    { '<C-p>', "<cmd>Telescope find_files<CR>" },
    {
      "<leader>ps",
      function()
        local ok, search = pcall(vim.fn.input, "Grep > ")
        if not ok or search == nil or search == "" then
          return
        end
        require('telescope.builtin').grep_string({ search = search })
      end,
      desc = "Grep with custom prompt"
    },
    { "<leader>pa", "<cmd>Telescope live_grep<CR>" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find Buffers" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent Files" },
    { '<leader>vh', "<cmd>Telescope help_tags<CR>" },
    { '<S-p>', "<cmd>Telescope commands<CR>" },
    {
      '<leader>gh',
      function()
        local telescope = require('telescope')
        telescope.load_extension("git_file_history")
        telescope.extensions.git_file_history.git_file_history()
      end
    },
  },
  config = function()
    local telescope = require('telescope')

    telescope.setup({
      pickers = {
        find_files = {
          theme = "dropdown",
          previewer = false,
        },
        git_files = {
          theme = "dropdown",
          previewer = false,
        },
      },
    })
  end
}

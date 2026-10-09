return {
  "nvim-telescope/telescope.nvim",
  version = "*", -- Track stable releases; the lockfile records the exact revision.
  cmd = "Telescope",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>pf", "<cmd>Telescope git_files<CR>" },
    { "<leader>pp", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
    { "<C-p>", "<cmd>Telescope find_files<CR>" },
    {
      "<leader>ps",
      function()
        local ok, search = pcall(vim.fn.input, "Grep > ")
        if not ok or search == nil or search == "" then
          return
        end
        require("telescope.builtin").grep_string({ search = search })
      end,
      desc = "Grep with custom prompt",
    },
    { "<leader>pa", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
    { "<leader>pb", "<cmd>Telescope buffers<CR>", desc = "Find Buffers" },
    { "<leader>pr", "<cmd>Telescope oldfiles<CR>", desc = "Recent Files" },
    { "<leader>vh", "<cmd>Telescope help_tags<CR>" },
    { "<S-p>", "<cmd>Telescope commands<CR>" },
  },
  config = function()
    local telescope = require("telescope")

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
  end,
}

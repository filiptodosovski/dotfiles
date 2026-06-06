return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    icons = {
      mappings = false, -- keep it text-only; matches the rest of your UI
    },
    spec = {
      { "<leader>b", group = "buffers" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>h", group = "harpoon" },
      { "<leader>l", group = "lsp" },
      { "<leader>p", group = "project / paste" },
      { "<leader>r", group = "reload / rename" },
      { "<leader>s", group = "sessions" },
      { "<leader>t", group = "test" },
      { "<leader>x", group = "trouble" },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer-local keymaps",
    },
  },
}

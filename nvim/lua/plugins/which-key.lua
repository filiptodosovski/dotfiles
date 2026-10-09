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
      { "<leader>g", group = "git" },
      { "<leader>p", group = "project / paste" },
      { "<leader>r", group = "reload / rename" },
      { "<leader>v", group = "references / help" },
      { "<leader>x", group = "trouble" },
    },
  },
}

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = { theme = "auto", globalstatus = true },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "filetype" },
      lualine_y = { "progress", "location" },
      lualine_z = {},
    },
    extensions = { "neo-tree", "lazy" },
  },
}

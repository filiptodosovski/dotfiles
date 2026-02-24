return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    notify_on_error = false,
    formatters_by_ft = {
      javascript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      scss = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      lua = { "stylua" },
      go = { "gofmt" },
      python = { "ruff_format", "black" },
    },
  },
}

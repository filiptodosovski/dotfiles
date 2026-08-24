return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    notify_on_error = false,
    default_format_opts = {
      lsp_format = "fallback",
      timeout_ms = 3000,
    },
    format_on_save = function(bufnr)
      -- Go already organizes imports and formats through gopls in lsp.lua.
      if vim.bo[bufnr].filetype == "go" then
        return
      end
      return {
        lsp_format = "fallback",
        timeout_ms = 3000,
      }
    end,
    formatters_by_ft = {
      javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      lua = { "stylua" },
      go = { "gofmt" },
      python = { "ruff_format" },
    },
  },
}

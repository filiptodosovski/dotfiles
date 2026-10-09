local function organize_go_imports(bufnr)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })[1]
  if not client then
    return
  end
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { "source.organizeImports" }, diagnostics = {} }
  local response = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
  for _, action in ipairs(response and response.result or {}) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
end

return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    default_format_opts = { lsp_format = "fallback", timeout_ms = 3000 },
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype == "go" then
        organize_go_imports(bufnr)
      end
      return { timeout_ms = 3000 }
    end,
    formatters_by_ft = {
      javascript = { "prettierd", "prettier", stop_after_first = true, lsp_format = "never" },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true, lsp_format = "never" },
      typescript = { "prettierd", "prettier", stop_after_first = true, lsp_format = "never" },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true, lsp_format = "never" },
      html = { "prettierd", "prettier", stop_after_first = true, lsp_format = "never" },
      css = { "prettierd", "prettier", stop_after_first = true, lsp_format = "never" },
      json = { "prettierd", "prettier", stop_after_first = true, lsp_format = "never" },
      lua = { "stylua" },
      python = { "ruff_format" },
      go = { "gofmt", lsp_format = "prefer" },
    },
  },
}

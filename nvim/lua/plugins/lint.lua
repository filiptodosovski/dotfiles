return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave" },
  config = function()
    local lint = require("lint")
    local fn = vim.fn

    lint.linters_by_ft = {
      -- JS/TS diagnostics come from the project-aware ESLint LSP.
      markdown = fn.executable("markdownlint") == 1 and { "markdownlint" } or {},
    }

    local lint_augroup = vim.api.nvim_create_augroup("NvimLint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        local ft = vim.bo.filetype
        local configured = lint.linters_by_ft[ft]
        if not configured or #configured == 0 then
          return
        end

        pcall(lint.try_lint)
      end,
    })
  end,
}

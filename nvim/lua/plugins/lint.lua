return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave" },
  config = function()
    local lint = require("lint")
    local fn = vim.fn

    local function pick_linter(...)
      for i = 1, select("#", ...) do
        local bin = select(i, ...)
        if fn.executable(bin) == 1 then
          return { bin }
        end
      end
      return {}
    end

    lint.linters_by_ft = {
      javascript = pick_linter("eslint_d", "eslint"),
      javascriptreact = pick_linter("eslint_d", "eslint"),
      typescript = pick_linter("eslint_d", "eslint"),
      typescriptreact = pick_linter("eslint_d", "eslint"),
      json = pick_linter("eslint_d", "eslint"),
      markdown = pick_linter("markdownlint"),
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

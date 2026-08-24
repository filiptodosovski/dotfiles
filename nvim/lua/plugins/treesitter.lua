local parsers = {
  "bash",
  "c",
  "clojure",
  "css",
  "go",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "rust",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
}

local filetypes = {
  "bash",
  "c",
  "clojure",
  "css",
  "go",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "lua",
  "markdown",
  "python",
  "query",
  "rust",
  "typescript",
  "typescriptreact",
  "vim",
  "vimdoc",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function(plugin)
    -- The main branch stores highlight queries below runtime/. Existing parsers
    -- migrated from the old branch may not have those query links yet.
    vim.opt.runtimepath:append(plugin.dir .. "/runtime")

    local treesitter = require("nvim-treesitter")
    treesitter.setup({})
    treesitter.install(parsers)

    local group = vim.api.nvim_create_augroup("Fit0Treesitter", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = filetypes,
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function(plugin)
    vim.opt.runtimepath:append(plugin.dir .. "/runtime")
    require("nvim-treesitter").setup({})
    -- Bootstrap installs parsers; opening the editor never starts installation.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("Fit0Treesitter", { clear = true }),
      callback = function(args)
        local parser = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if vim.tbl_contains(require("fit0.languages").parsers, parser) then
          pcall(vim.treesitter.start, args.buf)
        end
      end,
    })
  end,
}

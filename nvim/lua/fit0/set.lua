vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = true
vim.opt.backup = false
local undodir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p", 448) -- 0700
end
vim.fn.setfperm(undodir, "rwx------")
for name, kind in vim.fs.dir(undodir) do
  if kind == "file" then
    vim.uv.fs_chmod(vim.fs.joinpath(undodir, name), 384) -- 0600
  end
end
vim.opt.undodir = undodir
vim.opt.undofile = true

-- Secret files should never leave recoverable swap, backup, or undo history.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  pattern = {
    ".env",
    ".env.*",
    ".dev.vars",
    "*.key",
    "*.pem",
    "*.p12",
    "*.pfx",
    ".npmrc",
    ".pypirc",
    "credentials",
    "credentials.*",
  },
  callback = function(args)
    vim.bo[args.buf].swapfile = false
    vim.bo[args.buf].undofile = false
  end,
})

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.conceallevel = 1

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"
vim.opt.showmode = false

-- Avoid starting unused legacy providers on every Neovim launch.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    -- EditorConfig still wins when a Python project declares another style.
    if not vim.b.editorconfig then
      vim.bo.tabstop = 4
      vim.bo.softtabstop = 4
      vim.bo.shiftwidth = 4
    end
  end,
})

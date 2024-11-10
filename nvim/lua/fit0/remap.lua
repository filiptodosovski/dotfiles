vim.g.mapleader = " "

-- Unbind arrow keys, until I learn hjkl
vim.keymap.set("n", "<Up>", "<nop>")
vim.keymap.set("n", "<Down>", "<nop>")
vim.keymap.set("n", "<Left>", "<nop>")
vim.keymap.set("n", "<Right>", "<nop>")

-- Unbind arrow keys, until I learn hjkl
vim.keymap.set("i", "<Up>", "<nop>")
vim.keymap.set("i", "<Down>", "<nop>")
vim.keymap.set("i", "<Left>", "<nop>")
vim.keymap.set("i", "<Right>", "<nop>")

-- Unbind ESC key, until I learn C-c
vim.keymap.set("i", "<Esc>", "<nop>")

-- clear search highlights
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- Reload all buffers at once
vim.keymap.set("n", "<leader>ra", function()
  vim.cmd("bufdo e")
  print("Reloaded all buffers")
end)

vim.keymap.set("n", "<leader>rf", function()
  vim.cmd("bufdo e!")
  print("! Reloaded all buffers")
end)

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>po", [["_dP]])

-- next greatest remap ever : asbjornHaland

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])


vim.cmd [[ command! Paste execute 'read !xsel -b' ]]
-- vim.keymap.set({ "n", "v" }, "<leader>pp", "<cmd>Paste<CR>")
vim.keymap.set({ "n", "v" }, "<leader>P", [["+p]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format()
  local currentFileName = vim.fn.expand("%:t")

  if currentFileName:sub(-3) == ".ts" or currentFileName:sub(-4) == ".tsx" then
    vim.cmd("EslintFixAll")
  end
end
)

-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
vim.keymap.set("n", "<C-Y>", "<cmd>Neotree toggle <cr>")
vim.keymap.set("n", "<leader>rv", "<cmd>Neotree reveal<cr>", { desc = "Reveal the active file in the tree" })

-- buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bdd", "<cmd>:bd<cr>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bda", "<cmd>:%bd|e#|bd#<cr>", { desc = "Delete All Buffers But This One" })

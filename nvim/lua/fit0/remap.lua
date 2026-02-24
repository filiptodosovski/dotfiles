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

-- Return to file explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever - copy and delete the current word
vim.keymap.set("x", "<leader>po", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

if vim.fn.executable("pbpaste") == 1 then
  vim.cmd([[ command! Paste execute 'read !pbpaste' ]])
elseif vim.fn.executable("xsel") == 1 then
  vim.cmd([[ command! Paste execute 'read !xsel -b' ]])
elseif vim.fn.executable("xclip") == 1 then
  vim.cmd([[ command! Paste execute 'read !xclip -selection clipboard -o' ]])
end
-- vim.keymap.set({ "n", "v" }, "<leader>pp", "<cmd>Paste<CR>")
vim.keymap.set({ "n", "v" }, "<leader>P", [["+p]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ lsp_fallback = true })
  else
    vim.lsp.buf.format()
  end
end, { desc = "Format buffer" })

-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP Definition" })
vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, { desc = "LSP Implementation" })
vim.keymap.set("n", "<leader>lr", "<cmd>Trouble lsp_references toggle<cr>", { desc = "LSP References (Trouble)" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Chmod +x current file" })

vim.api.nvim_create_user_command("Format", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ lsp_fallback = true })
  else
    vim.lsp.buf.format()
  end
end, {})
vim.keymap.set("n", "<C-Y>", "<cmd>Neotree toggle <cr>")
vim.keymap.set("n", "<leader>rv", "<cmd>Neotree reveal<cr>", { desc = "Reveal the active file in the tree" })

-- open float window for errors
vim.keymap.set('n', '<leader>q', function()
  vim.diagnostic.open_float(nil, { scope = "cursor", focusable = true })
end, { noremap = true, silent = true, desc = "Show diagnostics at cursor" })

-- buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bdd", "<cmd>:bd<cr>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bda", "<cmd>:%bd|e#|bd#<cr>", { desc = "Delete All Buffers But This One" })

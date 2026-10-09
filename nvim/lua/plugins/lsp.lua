return {
  "neovim/nvim-lspconfig",
  dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim", "saghen/blink.cmp" },
  config = function()
    local languages = require("fit0.languages")
    -- Homebrew owns CLI tools; Mason supplies editor servers.
    require("mason").setup({ PATH = "append" })
    require("mason-lspconfig").setup({
      -- The installer manages downloads explicitly and waits for completion.
      ensure_installed = vim.env.DOTFILES_BOOTSTRAP == "1" and {} or languages.mason,
      automatic_enable = false,
    })
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

    vim.lsp.config("vtsls", {
      settings = {
        vtsls = { autoUseWorkspaceTsdk = true },
        typescript = { updateImportsOnFileMove = { enabled = "always" } },
      },
    })
    -- ESLint supplies diagnostics/fixes; Conform owns formatting.
    vim.lsp.config("eslint", { settings = { format = false } })
    vim.lsp.config("ruff", {
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false -- ty supplies Python hover.
      end,
    })
    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = true,
          gofumpt = true,
          staticcheck = true,
          analyses = { unusedparams = true },
        },
      },
    })
    vim.lsp.config("lua_ls", {
      cmd = {
        "lua-language-server",
        "--logpath=" .. vim.fn.stdpath("cache") .. "/lua-language-server",
      },
      settings = { Lua = {} },
      on_init = function(client)
        local workspace = client.workspace_folders and client.workspace_folders[1]
        local path = workspace and workspace.name
        if
          not path
          or vim.uv.fs_stat(path .. "/.luarc.json")
          or vim.uv.fs_stat(path .. "/.luarc.jsonc")
        then
          return
        end
        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
          runtime = { version = "LuaJIT" },
          workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
        })
      end,
    })
    vim.lsp.config("tailwindcss", {
      filetypes = {
        "html",
        "css",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
    })
    vim.lsp.enable(languages.servers)

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("Fit0Lsp", { clear = true }),
      callback = function(args)
        local mappings = {
          K = { vim.lsp.buf.hover, "Hover documentation" },
          gd = { vim.lsp.buf.definition, "Go to definition" },
          ["<leader>vrr"] = { vim.lsp.buf.references, "List references" },
          gD = { vim.lsp.buf.declaration, "Go to declaration" },
          gi = { vim.lsp.buf.implementation, "Go to implementation" },
          go = { vim.lsp.buf.type_definition, "Go to type definition" },
          gs = { vim.lsp.buf.signature_help, "Signature help" },
        }
        for key, mapping in pairs(mappings) do
          vim.keymap.set(
            "n",
            key,
            mapping[1],
            { buffer = args.buf, silent = true, desc = mapping[2] }
          )
        end
        vim.keymap.set("x", "<F3>", function()
          require("conform").format({ async = true })
        end, { buffer = args.buf, silent = true, desc = "Format selection" })
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "vtsls" then
          vim.keymap.set("n", "<leader>cV", function()
            client:request("workspace/executeCommand", {
              command = "typescript.selectTypeScriptVersion",
            }, nil, args.buf)
          end, { buffer = args.buf, silent = true, desc = "Select TypeScript version" })
        end
      end,
    })
    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = { current_line = true },
      severity_sort = true,
      signs = { text = { [1] = "E", [2] = "W", [3] = "I", [4] = "H" } },
    })
  end,
}

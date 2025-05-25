return {
  "VonHeikemen/lsp-zero.nvim",
  branch = "v3.x",
  dependencies = {
    -- LSP Support
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    -- Completion/snippets handled elsewhere, dependencies not needed here
  },
  config = function()
    local lsp = require("lsp-zero")
    local lspconfig = require("lspconfig")

    lsp.preset("recommended")

    -- Setup mason
    require("mason").setup()

    lsp.set_preferences({
      suggest_lsp_servers = false,
      sign_icons = { error = "E", warn = "W", hint = "H", info = "I" }
    })

    -- Formatting on save for eslint & go
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    local lsp_format_on_save = function(bufnr)
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          local ok = pcall(vim.cmd, "EslintFixAll")
          if not ok then vim.lsp.buf.format() end
        end,
      })
    end

    -- Default on_attach
    local on_attach = function(_, bufnr)
      lsp.default_keymaps({ buffer = bufnr })
    end
    lsp.on_attach(on_attach)

    -- Capabilities for cmp
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Per-server custom configuration
    lspconfig.ts_ls.setup({
      capabilities = capabilities,
      on_attach = function(_, bufnr)
        lsp_format_on_save(bufnr)
        on_attach(_, bufnr)
      end,
    })
    lspconfig.eslint.setup({})
    lspconfig.gopls.setup({
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = true,
          gofumpt = true,
          staticcheck = true,
          analyses = { unusedparams = true },
        },
      },
      on_attach = function(_, bufnr)
        lsp.default_keymaps({ buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          group = augroup,
          callback = function()
            local params = vim.lsp.util.make_range_params()
            params.context = { only = { "source.organizeImports" } }
            local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
            for cid, res in pairs(result or {}) do
              for _, r in pairs(res.result or {}) do
                if r.edit then
                  local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                  vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
              end
            end
            vim.lsp.buf.format({ async = false })
          end,
        })
      end,
    })

    -- Lua LSP config for Neovim
    lspconfig.lua_ls.setup({
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then return end
        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
          runtime = { version = "LuaJIT" },
          workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
        })
      end,
      settings = { Lua = {} },
    })

    -- Other LSPs with no/very little config, loop for DRYness
    for _, server in ipairs({ "rust_analyzer", "tailwindcss", "pyright", "clangd", "html", "clojure_lsp", "terraformls" }) do
      lspconfig[server].setup({})
    end

    vim.diagnostic.config({ virtual_text = false })

    lsp.setup()
  end,
}

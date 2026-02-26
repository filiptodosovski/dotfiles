return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
  },
  config = function()
    ---------------------------------------------------------------------------
    -- Mason
    ---------------------------------------------------------------------------
    require("mason").setup()

    ---------------------------------------------------------------------------
    -- Diagnostics signs
    ---------------------------------------------------------------------------
    local function setup_diagnostic_signs()
      local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end
    setup_diagnostic_signs()

    ---------------------------------------------------------------------------
    -- Formatting on save
    ---------------------------------------------------------------------------
    local formatting_augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    ---------------------------------------------------------------------------
    -- LSP keymaps
    ---------------------------------------------------------------------------
    local function set_default_keymaps(bufnr)
      local opts = { buffer = bufnr, silent = true }

      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
      vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)

      vim.keymap.set({ "n", "x" }, "<F3>", function()
        vim.lsp.buf.format({ async = true })
      end, opts)

      vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
    end

    -- helper to build on_attach with optional extra behaviour
    local function make_on_attach(extra)
      return function(client, bufnr)
        set_default_keymaps(bufnr)
        if extra then
          extra(client, bufnr)
        end
      end
    end

    ---------------------------------------------------------------------------
    -- Capabilities
    ---------------------------------------------------------------------------
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    ---------------------------------------------------------------------------
    -- Servers with custom configs
    ---------------------------------------------------------------------------
    local servers = {
      vtsls = {
        capabilities = capabilities,
        filetypes = {
          "javascript", "javascriptreact", "javascript.jsx",
          "typescript", "typescriptreact", "typescript.tsx",
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
        on_attach = make_on_attach(function(client, bufnr)
          -- pick workspace TS version
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "<leader>cV", function()
            client.request("workspace/executeCommand", {
              command = "typescript.selectTypeScriptVersion",
            })
          end, opts)
        end),
      },

      eslint = {
        capabilities = capabilities,
        on_attach = make_on_attach(), -- nothing special, just the defaults
      },

      gopls = {
        capabilities = capabilities,
        on_attach = make_on_attach(function(_, bufnr)
          -- organize imports + format on save for Go
          vim.api.nvim_clear_autocmds({ group = formatting_augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = formatting_augroup,
            buffer = bufnr,
            callback = function()
              local params = vim.lsp.util.make_range_params()
              params.context = { only = { "source.organizeImports" } }

              local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params)
              for cid, res in pairs(result or {}) do
                for _, r in pairs(res.result or {}) do
                  if r.edit then
                    local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                  end
                end
              end

              vim.lsp.buf.format({ async = false, bufnr = bufnr })
            end,
          })
        end),
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders    = true,
            gofumpt            = true,
            staticcheck        = true,
            analyses           = { unusedparams = true },
          },
        },
      },

      lua_ls = {
        capabilities = capabilities,
        on_attach = make_on_attach(),
        on_init = function(client)
          local uv = vim.uv or vim.loop
          local workspace = client.workspace_folders and client.workspace_folders[1]
          local path = workspace and workspace.name or nil
          if not path then return end

          if uv.fs_stat(path .. "/.luarc.json")
              or uv.fs_stat(path .. "/.luarc.jsonc")
          then
            -- user has their own config, respect it
            return
          end

          client.config.settings.Lua = vim.tbl_deep_extend(
            "force",
            client.config.settings.Lua,
            {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
              },
            }
          )
        end,
        settings = { Lua = {} },
      },
    }

    -- register + enable servers with custom config
    for name, config in pairs(servers) do
      vim.lsp.config(name, config)
      vim.lsp.enable(name)
    end

    ---------------------------------------------------------------------------
    -- “Simple” servers that just share capabilities + on_attach
    ---------------------------------------------------------------------------
    local simple_servers = {
      "rust_analyzer",
      "tailwindcss",
      "pyright",
      "clangd",
      "html",
      "clojure_lsp",
      "terraformls",
      "prismals",
    }

    local simple_base_config = {
      capabilities = capabilities,
      on_attach = make_on_attach(),
    }

    for _, name in ipairs(simple_servers) do
      vim.lsp.config(name, simple_base_config)
      vim.lsp.enable(name)
    end

    ---------------------------------------------------------------------------
    -- Diagnostics UI
    ---------------------------------------------------------------------------
    vim.diagnostic.config({
      virtual_text = false,
    })
  end,
}

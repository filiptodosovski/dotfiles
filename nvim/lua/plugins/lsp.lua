return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "mason-org/mason.nvim" },
    { "mason-org/mason-lspconfig.nvim" },
    { "SmiteshP/nvim-navic" },
    { "saghen/blink.cmp" },
    { "b0o/SchemaStore.nvim", lazy = true, version = false },
  },
  config = function()
    ---------------------------------------------------------------------------
    -- Mason
    ---------------------------------------------------------------------------
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "vtsls",
        "eslint",
        "gopls",
        "lua_ls",
        "rust_analyzer",
        "tailwindcss",
        "ruff",
        "ty",
        "clangd",
        "html",
        "terraformls",
        "prismals",
        "jsonls",
        "yamlls",
      },
      -- Every server is configured/enabled explicitly below. This prevents Mason
      -- from also starting ts_ls beside VTSLS or the native TypeScript server.
      automatic_enable = false,
    })

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

    local navic_ok, navic = pcall(require, "nvim-navic")

    local function make_on_attach(extra)
      return function(client, bufnr)
        set_default_keymaps(bufnr)
        if navic_ok and client.server_capabilities.documentSymbolProvider then
          pcall(navic.attach, client, bufnr)
        end
        if extra then
          extra(client, bufnr)
        end
      end
    end

    ---------------------------------------------------------------------------
    -- Capabilities
    ---------------------------------------------------------------------------
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

    ---------------------------------------------------------------------------
    -- TypeScript 7 native LSP when available; VTSLS for current TS projects
    ---------------------------------------------------------------------------
    local function typescript_root(bufnr)
      return vim.fs.root(bufnr, {
        "package.json",
        "tsconfig.json",
        "jsconfig.json",
        ".git",
      }) or vim.fn.getcwd()
    end

    local function typescript_major(command)
      local result = vim.system({ command, "--version" }, { text = true }):wait()
      if result.code ~= 0 then
        return nil
      end
      return tonumber((result.stdout or ""):match("(%d+)"))
    end

    local function has_native_typescript(bufnr)
      local root = typescript_root(bufnr)
      local local_commands = {
        root .. "/node_modules/.bin/tsc",
        root .. "/node_modules/.bin/tsgo",
      }

      local has_local_typescript = false
      for _, command in ipairs(local_commands) do
        if vim.fn.executable(command) == 1 then
          has_local_typescript = true
          if (typescript_major(command) or 0) >= 7 then
            return true
          end
        end
      end

      if has_local_typescript then
        return false
      end

      for _, command in ipairs({ "tsc", "tsgo" }) do
        if vim.fn.executable(command) == 1 and (typescript_major(command) or 0) >= 7 then
          return true
        end
      end

      return false
    end

    local default_vtsls_root_dir = vim.lsp.config.vtsls.root_dir
    local default_tsc_root_dir = vim.lsp.config.tsc.root_dir
    local default_eslint_root_dir = vim.lsp.config.eslint.root_dir
    local default_eslint_on_attach = vim.lsp.config.eslint.on_attach

    local function has_project_eslint(root, bufnr)
      if vim.uv.fs_stat(root .. "/.pnp.cjs") or vim.uv.fs_stat(root .. "/.pnp.js") then
        return true
      end

      local directory = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
      root = vim.fs.normalize(root)

      while directory and directory:sub(1, #root) == root do
        if
          vim.uv.fs_stat(directory .. "/node_modules/eslint/package.json")
          or vim.fn.executable(directory .. "/node_modules/.bin/eslint") == 1
        then
          return true
        end

        if directory == root then
          break
        end

        local parent = vim.fs.dirname(directory)
        if parent == directory then
          break
        end
        directory = parent
      end

      return false
    end

    ---------------------------------------------------------------------------
    -- Servers with custom configs
    ---------------------------------------------------------------------------
    local servers = {
      vtsls = {
        capabilities = capabilities,
        root_dir = function(bufnr, on_dir)
          if not has_native_typescript(bufnr) then
            default_vtsls_root_dir(bufnr, on_dir)
          end
        end,
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
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
            client:request("workspace/executeCommand", {
              command = "typescript.selectTypeScriptVersion",
            })
          end, opts)
        end),
      },

      -- nvim-lspconfig starts this only when a TypeScript >= 7 CLI is present.
      tsc = {
        capabilities = capabilities,
        root_dir = function(bufnr, on_dir)
          if has_native_typescript(bufnr) then
            default_tsc_root_dir(bufnr, on_dir)
          end
        end,
        on_attach = make_on_attach(),
      },

      eslint = {
        capabilities = capabilities,
        root_dir = function(bufnr, on_dir)
          default_eslint_root_dir(bufnr, function(root)
            -- The language server is only the transport. The actual ESLint
            -- library must come from the project (or Yarn Plug'n'Play).
            if has_project_eslint(root, bufnr) then
              on_dir(root)
            end
          end)
        end,
        on_attach = make_on_attach(function(client, bufnr)
          if default_eslint_on_attach then
            default_eslint_on_attach(client, bufnr)
          end
        end),
      },

      ruff = {
        capabilities = capabilities,
        on_attach = make_on_attach(function(client)
          -- Let ty own Python hover information; Ruff owns linting/fixes.
          client.server_capabilities.hoverProvider = false
        end),
      },

      gopls = {
        capabilities = capabilities,
        on_attach = make_on_attach(function(client, bufnr)
          -- organize imports + format on save for Go
          vim.api.nvim_clear_autocmds({ group = formatting_augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = formatting_augroup,
            buffer = bufnr,
            callback = function()
              local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
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
            usePlaceholders = true,
            gofumpt = true,
            staticcheck = true,
            analyses = { unusedparams = true },
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
          if not path then
            return
          end

          if uv.fs_stat(path .. "/.luarc.json") or uv.fs_stat(path .. "/.luarc.jsonc") then
            -- user has their own config, respect it
            return
          end

          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME },
            },
          })
        end,
        settings = { Lua = {} },
      },

      jsonls = {
        capabilities = capabilities,
        on_attach = make_on_attach(),
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      },

      yamlls = {
        capabilities = capabilities,
        on_attach = make_on_attach(),
        settings = {
          yaml = {
            schemaStore = {
              -- disable built-in schema store to use SchemaStore.nvim instead
              enable = false,
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
            validate = true,
          },
        },
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
      "ty",
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
      virtual_lines = { current_line = true },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "E",
          [vim.diagnostic.severity.WARN] = "W",
          [vim.diagnostic.severity.INFO] = "I",
          [vim.diagnostic.severity.HINT] = "H",
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
          [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
          [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
          [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
      },
    })

    vim.keymap.set("n", "<leader>e", function()
      local cur = vim.diagnostic.config().virtual_lines
      vim.diagnostic.config({
        virtual_lines = not cur and { current_line = true } or false,
      })
    end, { desc = "Toggle diagnostic virtual_lines" })
  end,
}

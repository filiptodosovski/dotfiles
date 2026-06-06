return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "*", -- use latest tagged release; ships precompiled fuzzy matcher
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = (vim.fn.has("win32") == 0 and vim.fn.executable("make") == 1)
          and "make install_jsregexp"
        or nil,
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_vscode").lazy_load({
          paths = vim.fn.stdpath("config") .. "/snippets",
        })
      end,
    },
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "default",
      ["<C-y>"] = { "select_and_accept" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
    },

    snippets = { preset = "luasnip" },

    appearance = {
      nerd_font_variant = "mono",
    },

    completion = {
      list = {
        selection = { preselect = true, auto_insert = false },
      },
      menu = {
        border = "rounded",
        draw = { treesitter = { "lsp" } },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
      ghost_text = { enabled = false },
    },

    signature = {
      enabled = true,
      window = { border = "rounded" },
    },

    sources = {
      default = { "lsp", "snippets", "path", "buffer" },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}

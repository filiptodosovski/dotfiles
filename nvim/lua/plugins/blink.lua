return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "1.*", -- stable v1 releases; v2 needs a deliberate migration
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "default",
      ["<C-y>"] = { "select_and_accept" },
      ["<CR>"] = { "select_and_accept", "fallback" },
      ["<C-Space>"] = { "show" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
    },

    snippets = { preset = "default" }, -- Neovim's built-in snippet engine.

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

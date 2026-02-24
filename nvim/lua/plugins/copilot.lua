return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = '<C-Tab>',
          accept_word = '<C-W>',
          accept_line = '<C-l>',
          next = '<C-]>',
          prev = '<C-[>',
          dismiss = '<C-e>',
        },
      },
      copilot_node_command = 'node',
      server_opts_overrides = {},
    },
  },
}

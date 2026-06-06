return {
  {
    "nvim-mini/mini.ai",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "nvim-mini/mini.surround",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "nvim-mini/mini.pairs",
    version = false,
    event = "InsertEnter",
    opts = {},
  },
  {
    "nvim-mini/mini.comment",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring()
            or vim.bo.commentstring
        end,
      },
    },
  },
}

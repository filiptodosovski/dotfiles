return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      numbers = "none",
      get_element_icon = function(element)
        if element.directory then
          return ""
        end
        local icon = require("nvim-web-devicons").get_icon(
          vim.fn.fnamemodify(element.path, ":t"),
          element.extension,
          { default = true }
        )
        -- Return only the glyph: inherit the label's foreground and background.
        return icon
      end,
    },
  },
}

return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function ()
    vim.opt.termguicolors = true
    require("bufferline").setup({
      options = {
        themable = true,
        diagnostics = "nvim_lsp",
        color_icons = true,
        custom_filter = function(buf_number)
          local filetype = vim.bo[buf_number].filetype
          if filetype == "" then
            return false
          end

          return true
        end,

        -- sort_by = function(buffer_a, buffer_b)
        --   local a = 1
        --   local b = 1
        --
        --   local marks = require('harpoon'):list()
        --
        --   for _, mark in ipairs(marks.items) do
        --     if vim.fn.bufname(buffer_a.id) == mark.value then
        --       a = 0
        --       break
        --     elseif vim.fn.bufname(buffer_b.id) == mark.value then
        --       b = 0
        --       break
        --     end
        --   end
        --   return a < b
        -- end,

        numbers = function(number_opts)
          local harpoon = require("harpoon")
          local buf_name = vim.fn.bufname(number_opts.id)
          local harpoon_list = harpoon:list()
          local harpoon_mark
          for index, item in ipairs(harpoon_list.items) do
            if buf_name == item.value then
              harpoon_mark = index
              break
            end
          end

          return harpoon_mark
        end,
      }
    })
  end
}

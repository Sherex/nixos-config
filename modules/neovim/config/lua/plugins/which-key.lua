return {
  "folke/which-key.nvim",
  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    local wk = require("which-key")
    wk.register({
      ["<leader>e"] = { name = "+NvimTree" },
    })
  end,
}

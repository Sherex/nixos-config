-- Install Lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Disable netrw for nvim-tree (has to be at the top of the file)
-- https://github.com/nvim-tree/nvim-tree.lua#quick-start
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set termguicolors to enable highlight groups
-- https://github.com/nvim-tree/nvim-tree.lua#quick-start
-- :h termguicolors
vim.opt.termguicolors = true

-- Enable line numbering
vim.opt.number = true
vim.opt.relativenumber = true

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- TODO: Move to own modules
require("lazy").setup({
  {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      local wk = require("which-key")
      wk.register({
        ["<leader>e"] = { name = "+NvimTree" },
      })
    end,
  },

  { "folke/neoconf.nvim", cmd = "Neoconf" },

  "folke/neodev.nvim",

  "folke/trouble.nvim",

  { 
    "nvim-tree/nvim-tree.lua",
    keys = {
      { "<leader>ee", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
      { "<leader>ef", "<cmd>NvimTreeFindFile<cr>", desc = "Find file in NvimTree" },
    },
    config = {
      renderer = {
        icons = {
          show = {
            git = true,
          },
        },
        highlight_git = true,
      },
      modified = {
        enable = true,
      },
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
    },
  },

  {
  "folke/tokyonight.nvim",
  opts = {
    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
  },
}
})

-- Set colorscheme
vim.cmd.colorscheme("tokyonight")


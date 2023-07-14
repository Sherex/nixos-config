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
    opts = {
      renderer = {
        icons = {
          show = {
            git = true,
          },
        },
        highlight_git = true,
      },
      view = {
        relativenumber = true,
        float = {
          enable = true,
        },
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
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      numhl = true,
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { "<leader>tt", "<cmd>Telescope<cr>", desc = "Open Telescope" },
      { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find file" },
      { "gs", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "gS", "<cmd>Telescope grep_string<cr>", desc = "Grep string under cursor" },
    },
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
      {
        "<S-j>",
        "<cmd>BufferLineCycleNext<cr>",
        desc = "Cycle next bufferline"
      },
      {
        "<S-k>",
        "<cmd>BufferLineCyclePrev<cr>",
        desc = "Cycle pervious bufferline"
      },
      {
        "<leader><S-c>",
        "<cmd>bdelete!<cr>",
        desc = "Close current buffer (force)"
      },
      {
        "<leader>c",
        "<cmd>bdelete<cr>",
        desc = "Close current buffer"
      },
      {
        "<leader>bc",
        "<cmd>BufferLinePickClose<cr>",
        desc = "Pick a buffer in the bufferline to close"
      },
      {
        "<leader>bk",
        "<cmd>BufferLineCloseLeft<cr>",
        desc = "Close all to the left in bufferline"
      },
      {
        "<leader>bj",
        "<cmd>BufferLineCloseRight<cr>",
        desc = "Close all to the right in bufferline"
      },
    },
    opts = {
      options = {
        close_command = "bdelete %d",
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      auto_install = true,
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
  },

  {
    "akinsho/toggleterm.nvim",
    config = true,
    keys = {
      {
        "<A-3>",
        "<cmd>ToggleTerm size=40 direction=float<cr>",
        mode = {"n", "t"},
        desc = "Toggle floating terminal"
      },
      {
        "<A-2>",
        "<cmd>ToggleTerm size=20 direction=horizontal<cr>",
        mode = {"n", "t"},
        desc = "Toggle horizontal terminal"
      },
    },
  },

  {
    "gpanders/editorconfig.nvim",
    config = false,
  },
})

-- Set colorscheme
vim.cmd.colorscheme("tokyonight")


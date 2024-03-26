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

  {
    "folke/trouble.nvim",
    lazy = false,
    keys = {
      { "<leader>te", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble window" },
      { "gr", "<cmd>Trouble lsp_references<cr>", desc = "Show references for word under cursor" },
    },
  },

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
      { "gs", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "gS", "<cmd>Telescope grep_string<cr>", desc = "Grep string under cursor" },
      { "<leader>f", function () require('telescope.builtin').find_files({ hidden = true }) end, desc = "Find file" },
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

  {
    "rcarriga/nvim-notify",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function ()
      vim.opt.termguicolors = true
      vim.notify = require("notify").setup({
        background_colour = "#000000",
        render = "compact",
        timeout = 1000,
      })
    end,
    keys = {
      {
        "<leader>n",
        "<cmd>Telescope notify<cr>",
        desc = "Open notifications log in Telescope"
      },
    },
  },

  {
    "hrsh7th/cmp-nvim-lsp",
    config = true,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function ()
      local lspconfig = require("lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local servers = {
        "nil_ls",
        "jsonls",
        "terraform_lsp",
        "tsserver",
        "volar", -- Vue
        "yamlls",
      }
      for _, lsp in ipairs(servers) do
        -- TODO: Setup can only be called once per LSP
        lspconfig[lsp].setup {
          capabilities = capabilities,
        }
      end

      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        settings = {
            Lua = {
              runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
              },
              diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'},
              },
              workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
              },
              -- Do not send telemetry data containing a randomized but unique identifier
              telemetry = {
                enable = false,
              },
            },
          },
      }
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    config = true,
  },

  {
    "saadparwaiz1/cmp_luasnip",
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function ()
      local luasnip = require 'luasnip'
      local cmp = require 'cmp'
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
          ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
          -- C-b (back) C-f (forward) for snippet placeholder navigation.
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      }
    end,
  },

  {
    "b0o/schemastore.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function ()
      require("lspconfig").jsonls.setup {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      }
    end,
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true;
  },

  {
    "elihunter173/dirbuf.nvim",
    keys = {
      { "<leader>eE", "<cmd>Dirbuf<cr>", desc = "Open Dirbuf" },
    },
  },

})

-- Set colorscheme
vim.cmd.colorscheme("tokyonight")


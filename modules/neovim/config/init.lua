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

-- Set tabs to spaces as default
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable window title
vim.opt.title = true

--- A wrapper to configure a source for nvim_cmp
--- @param name string
--- @param option table?
local function configure_cmp_source(name, option)
  local cmp = require('cmp')
  local config = cmp.get_config()
  table.insert(config.sources, {
    name = name,
    option = option,
  })
  cmp.setup(config)
end

-- TODO: Move to own modules
require("lazy").setup({
  {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      local wk = require("which-key")
      wk.add({
        { "<leader>e", group = "NvimTree" },
        { "<leader>l", group = "Lsp" },
      })
    end,
  },

  { "folke/neoconf.nvim",       cmd = "Neoconf" },

  "folke/neodev.nvim",

  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>te", "<cmd>TroubleToggle<cr>",          desc = "Toggle Trouble window" },
      { "gr",         "<cmd>Trouble lsp_references<cr>", desc = "Show references for word under cursor" },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    keys = {
      { "<leader>ee", "<cmd>NvimTreeToggle<cr>",   desc = "Toggle NvimTree" },
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
    "nvimdev/lspsaga.nvim",
    opts = {
      code_action = {
        extend_gitsigns = true,
      },
      hover = {
        open_link = 'gx',     -- key for opening links
        --open_cmd = '!xdg-open', -- cmd for opening links
      },
      symbol_in_winbar = {
        enable = true,
      },
      ui = {
        code_action = "✨",
      }
    },
    event = 'LspAttach',
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    },
    keys = {
      {
        "ga",
        "<cmd>Lspsaga code_action<cr>",
        desc = "Select code action"
      },
      {
        "<leader>lr",
        "<cmd>Lspsaga finder ref+imp<cr>",
        desc = "Find method ref/impl"
      },
      {
        "<leader>lR",
        "<cmd>Lspsaga finder def+ref+imp<cr>",
        desc = "Find method ref/impl"
      },
      {
        "<leader>lo",
        "<cmd>Lspsaga outline<cr>",
        desc = "Show buffer outline"
      },
      {
        "<leader>lr",
        "<cmd>Lspsaga rename<cr>",
        desc = "Rename symbol under cursor in buffer"
      },
      {
        "<C-h>",
        "<cmd>Lspsaga hover_doc<cr>",
        desc = "Show hover documentation ('gx' for URLs)"
      },
      {
        "<leader>lj",
        "<cmd>Lspsaga diagnostic_jump_next<cr>",
        desc = "Jump to next diagnostic"
      },
      {
        "<leader>lk",
        "<cmd>Lspsaga diagnostic_jump_prev<cr>",
        desc = "Jump to previous diagnostic"
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { "<leader>tt", "<cmd>Telescope<cr>",                                                       desc = "Open Telescope" },
      { "gs",         "<cmd>Telescope live_grep<cr>",                                             desc = "Live grep" },
      { "gS",         "<cmd>Telescope grep_string<cr>",                                           desc = "Grep string under cursor" },
      { "<leader>f",  function() require('telescope.builtin').find_files({ hidden = true }) end,  desc = "Find file" },
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
        mode = { "n", "t" },
        desc = "Toggle floating terminal"
      },
      {
        "<A-2>",
        "<cmd>ToggleTerm size=20 direction=horizontal<cr>",
        mode = { "n", "t" },
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
    config = function()
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
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local servers = {
        "nil_ls",
        "jsonls",
        "terraform_lsp",
        "ts_ls",
        "volar", -- Vue
        "yamlls",
        "bashls",
        "denols",
        "lemminx",
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
              globals = { 'vim' },
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

      require'lspconfig'.omnisharp.setup {
        cmd = { "OmniSharp" },

        settings = {
          FormattingOptions = {
            -- Enables support for reading code style, naming convention and analyzer
            -- settings from .editorconfig.
            EnableEditorConfigSupport = true,
            -- Specifies whether 'using' directives should be grouped and sorted during
            -- document formatting.
            OrganizeImports = nil,
          },
          MsBuild = {
            -- If true, MSBuild project system will only load projects for files that
            -- were opened in the editor. This setting is useful for big C# codebases
            -- and allows for faster initialization of code navigation features only
            -- for projects that are relevant to code that is being edited. With this
            -- setting enabled OmniSharp may load fewer projects and may thus display
            -- incomplete reference lists for symbols.
            LoadProjectsOnDemand = nil,
          },
          RoslynExtensionsOptions = {
            -- Enables support for roslyn analyzers, code fixes and rulesets.
            EnableAnalyzersSupport = true,
            -- Enables support for showing unimported types and unimported extension
            -- methods in completion lists. When committed, the appropriate using
            -- directive will be added at the top of the current file. This option can
            -- have a negative impact on initial completion responsiveness,
            -- particularly for the first few completion sessions after opening a
            -- solution.
            EnableImportCompletion = true,
            -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
            -- true
            AnalyzeOpenDocumentsOnly = nil,
          },
          Sdk = {
            -- Specifies whether to include preview versions of the .NET SDK when
            -- determining which version to use for project loading.
            IncludePrereleases = true,
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
    dependencies = {
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
    },
    init = function()
      configure_cmp_source('luasnip')
    end,
  },

  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    dependencies = { "hrsh7th/nvim-cmp" },
    init = function()
      configure_cmp_source('nvim_lsp_signature_help')
    end,
  },

  {
    name = "cmp-async-path",
    url = "https://codeberg.org/FelipeLema/cmp-async-path.git",
    dependencies = { "hrsh7th/nvim-cmp" },
    init = function()
      configure_cmp_source('async_path')
    end,
  },

  {
    "windwp/nvim-autopairs",
    dependencies = { "hrsh7th/nvim-cmp" },
    event = "InsertEnter",
    config = true,
    init = function()
      -- Insert `(` after select function or method item
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      require('cmp').event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "olimorris/codecompanion.nvim",
    },
    config = function()
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
          ['<C-d>'] = cmp.mapping.scroll_docs(4),  -- Down
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
          {
            name = 'nvim_lsp',
            per_filetype = {
              codecompanion = { "codecompanion" },
            },
          },
        },
      }
    end,
  },

  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      display = {
        chat = {
          show_settings = true,
        },
      },
      strategies = {
        chat = {
          adapter = "ollama",
        },
        inline = {
          adapter = "ollama",
        },
        cmd = {
          adapter = "ollama",
        }
      },
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            env = {
              url = "http://archy:11434",
            },
          })
        end,
      },
    },
  },

  {
    "b0o/schemastore.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
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
    config = true,
  },

  {
    "elihunter173/dirbuf.nvim",
    keys = {
      { "<leader>eE", "<cmd>Dirbuf<cr>", desc = "Open Dirbuf" },
    },
  },

  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    config = true,
  },

  {
    "echasnovski/mini.sessions",
    lazy = false,
    opts = {
      autoread = false,
      autowrite = true,
    },
  },

  {
    "echasnovski/mini.starter",
    lazy = false,
    opts = {
      autoopen = true,
      evaluate_single = true,
    },
  },

  {
    "echasnovski/mini.statusline",
    lazy = false,
    opts = {
      -- Content of statusline as functions which return statusline string. See
      -- `:h statusline` and code of default contents (used instead of `nil`).
      content = {
        active = nil,
        inactive = nil,
      },
    }
  },

  { "kevinhwang91/nvim-hlslens" },

  {
    "petertriho/nvim-scrollbar",
    dependencies = {
      "kevinhwang91/nvim-hlslens",
      "lewis6991/gitsigns.nvim",
      "folke/tokyonight.nvim",
    },
    lazy = false,
    config = function()
      local colors = require("tokyonight.colors").setup()
      local opts = {
        handle = {
          color = colors.bg_highlight,
        },
        marks = {
          Search = { color = colors.orange },
          Error = { color = colors.error },
          Warn = { color = colors.warning },
          Info = { color = colors.info },
          Hint = { color = colors.hint },
          Misc = { color = colors.purple },
        },
      }

      require("scrollbar").setup(opts)
      require("scrollbar.handlers.gitsigns").setup()
      require("scrollbar.handlers.search").setup()
    end
  },

  {
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },

  {
    "chentoast/marks.nvim",
    opts = {
      default_mappings = false,
      builtin_marks = { ".", "<", ">", "^", "[", "]" },
    },
  },

  {
    "ggandor/leap.nvim",
    config = true,
    keys = {
      { "s", "<Plug>(leap)", desc = "Leap search" },
    },
  },

})

-- Set colorscheme
vim.cmd.colorscheme("tokyonight")

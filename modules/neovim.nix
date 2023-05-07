{ config, pkgs, lib, ... }:

{
  imports = [ <home-manager/nixos> ];

  home-manager.users.sherex = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      extraLuaConfig = ''
        -- Disable netrw for nvim-tree (has to be at the top of the file)
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        -- Enable line numbering
        vim.opt.number = true
        vim.opt.relativenumber = true

        -- Set leader key
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '
      '';
      extraPackages = [
        pkgs.gcc
      ];
      plugins = with pkgs.vimPlugins; [
        plenary-nvim
	{
	  plugin = nvim-tree-lua;
	  config = ''
            packadd! nvim-tree.lua
            lua vim.opt.termguicolors = true
            lua require("nvim-tree").setup()
	  '';
	}
	{
          plugin = vim-startify;
          config = "let g:startify_change_to_vcs_root = 0";
	}
        (nvim-treesitter.withPlugins (p: [
	  # https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
	  p.lua
	  p.bash
	  p.c_sharp
	  p.comment
	  p.dockerfile
	  p.git_config
	  p.git_rebase
	  p.gitattributes
	  p.gitcommit
	  p.gitignore
	  p.html
	  p.css
	  p.ini
	  p.javascript
	  p.json
	  p.nix
	  p.regex
	  p.terraform
	  p.toml
	  p.typescript
	  p.yaml
	]))
	nvim-web-devicons # https://github.com/nvim-tree/nvim-web-devicons
	telescope-fzf-native-nvim # https://github.com/nvim-telescope/telescope-fzf-native.nvim
	telescope-nvim
	{
	  plugin = which-key-nvim;
          config = ''
            packadd! which-key.nvim
            lua require("which-key").setup()
	  '';
	}
      ];
    };
  };
}

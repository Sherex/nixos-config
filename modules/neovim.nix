{ config, pkgs, lib, ... }:

{
  imports = [ <home-manager/nixos> ];

  home-manager.users.sherex = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      plugins = [
        pkgs.vimPlugins.nvim-tree-lua
	{
          plugin = pkgs.vimPlugins.vim-startify;
          config = "let g:startify_change_to_vcs_root = 0";
	}
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
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
      ];
    };
  };
}

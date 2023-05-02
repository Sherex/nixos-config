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
      ];
    };
  };
}

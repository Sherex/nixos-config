{ config, pkgs, lib, ... }:

{
  imports = [ <home-manager/nixos> ];

  home-manager.users.sherex = { pkgs, ... }: {
   home.file."./.config/nvim/" = {
     source = ./config;
     recursive = true;
   };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      extraPackages = [
        pkgs.gcc # Treesitter dependency
        pkgs.tree-sitter # Treesitter dependency
        pkgs.nodejs # Treesitter dependency
      ];
    };
  };
}

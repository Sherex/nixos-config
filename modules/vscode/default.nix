{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex.programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };
}


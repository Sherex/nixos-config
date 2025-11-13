{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ../users/common.nix
    ../modules/bash
    ../modules/neovim
    ../modules/git
  ];

  users.users.sherex = {
    linger = true;
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
    ];
  };
}

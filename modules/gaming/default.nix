{ config, pkgs, lib, ... }:

{
  programs.steam = {
    enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
    extraPackages = [
      pkgs.gamemode
    ];
  };

  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      vesktop
    ];
  };
}


{ config, pkgs, lib, ... }:

{
  programs.steam = {
    enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };

  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      vesktop
    ];
  };
}


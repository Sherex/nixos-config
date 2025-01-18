{ config, pkgs, lib, ... }:

{
  programs.steam = {
    enable = true;
  };

  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      vesktop
    ];
  };
}


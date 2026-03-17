{ config, pkgs, lib, ... }:

{
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = {
        DBUS_SYSTEM_BUS_ADDRESS="";
      };
    };
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
    extraPackages = [
      pkgs.gamemode
      pkgs.gamescope
      pkgs.mangohud
    ];
  };

  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      vesktop
    ];
  };
}


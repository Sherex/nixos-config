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
    gamescopeSession = {
      enable = true;
      args = [
        "-W 3440"
        "-H 1440"
        "-w 1720"
        "-h 720"
        "--expose-wayland"
        #"-S integer"
        #"-r 120"
      ];
    };
  };

  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      vesktop
    ];
  };
}


{ config, pkgs, lib, home-manager, ... }:

let
  kodi-wayland = (pkgs.kodi-wayland.withPackages (kodiPkgs: with kodiPkgs; [
    jellyfin
    inputstream-adaptive
    inputstream-rtmp
    inputstream-ffmpegdirect
	]));
in {
  # Define a user account
  users.extraUsers.kodi = {
    isNormalUser = true;
    extraGroups = [
      "dialout"
      config.users.groups.nix-allowed.name
    ];
  };
  services.cage.user = "kodi";
  services.cage.program = "${kodi-wayland}/bin/kodi-standalone";
  services.cage.enable = true;
  systemd.services.cage-tty1.serviceConfig = {
    ExecStop = "${pkgs.killall}/bin/killall --exact --wait kodi.bin";
  };

  nixpkgs.config.kodi.enableAdvancedLauncher = true;

  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    #allowedUDPPorts = [ ];
  };

  home-manager.users.kodi = { pkgs, ... }: {
    home.stateVersion = "22.11";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [
      alsa-utils
    ];
  };
}


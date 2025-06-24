{ config, pkgs, lib, home-manager, ... }:

let
  kodi-wayland = (pkgs.kodi-wayland.withPackages (kodiPkgs: with kodiPkgs; [
		jellyfin
		jellycon
	]));
in {
  # Define a user account
  users.extraUsers.kodi = {
    isNormalUser = true;
    extraGroups = [ "dialout" ];
  };
  services.cage.user = "kodi";
  services.cage.program = "${kodi-wayland}/bin/kodi-standalone";
  services.cage.enable = true;

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


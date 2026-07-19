{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../common-server.nix
    ../../modules/nginx
    ../../modules/mealie
    ../../modules/headscale
    ../../modules/containerization
    ../../modules/web/karlsentertainment
    ../../modules/renovate
    ../../modules/garage
    ../../modules/atuin-server
    ../../modules/findmydevice
    ../../modules/sftpgo
    ../../modules/homeassistant
    ../../modules/calibre-web
    ../../modules/openwebui
    ../../modules/observability
    ../../modules/qui
    ../../modules/forgejo
    ../../modules/victorialogs
    ../../modules/vaultwarden
  ];

  networking.hostName = "Nixxy";

  networking.wireless.enable = false;

  boot.swap.enable = true;
  boot.swap.offset = 4465920;

  # TODO: Setup Sops-nix and backup for Nixxy
  backup.enable = false;
  # backup.borgbaseId = "";

  observability.enable = true;
  victorialogs.enable = true;
  forgejo.enable = true;
  forgejo.localRunner.enable = true;
  vaultwarden.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}


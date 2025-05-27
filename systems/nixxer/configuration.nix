{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./disko.nix
    ../common-server.nix
    ../../modules/containers/minecraft-servers.nix
    ../../modules/containers/satisfactory-servers.nix
    ../../modules/containers/jellyfin.nix
    ../../modules/vpn-wireguard
  ];

  networking.hostName = "Nixxer";

  networking.wireless.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}


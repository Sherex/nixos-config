{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../common-desktop.nix
    ../../modules/gaming
    ../../modules/virtualization
    ../../modules/sunshine
  ];

  networking.hostName = "Archy";

  networking.wireless.enable = true;

  boot = {
    kernelParams = [
      # enable IOMMU
      "intel_iommu=on"
    ];
    swap.enable = true;
    swap.offset = 4768391;
  };

  backup.enable = true;
  backup.borgbaseId = "vf5v43p8";

  hardware.graphics.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}


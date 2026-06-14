{ config, lib, pkgs, ... }:

{
  imports = [
    ../systems/common.nix
    ../users/sherex-desktop.nix
    ../modules/hyprland
    ../modules/sound
    ../modules/vpn
    ../modules/kde-connect
    ../modules/bluetooth
  ];

  boot.loader.grub.default = "saved";
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}


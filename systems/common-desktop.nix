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
}


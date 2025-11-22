{ config, lib, pkgs, ... }:

{
  imports = [
    ../systems/common.nix
    ../users/sherex-desktop.nix
    ../modules/gpu
    ../modules/hyprland
    ../modules/sound
    ../modules/vpn
    ../modules/kde-connect
  ];

  boot.loader.grub.default = "saved";
}


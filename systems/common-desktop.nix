{ config, lib, pkgs, ... }:

{
  imports = [
    ../systems/common.nix
    ../users/sherex-desktop.nix
    ../modules/gpu
    ../modules/hyprland
    ../modules/sound
    ../modules/sops # TODO: Make configurable and add to systems/common.nix
    ../modules/vpn
    ../modules/kde-connect
  ];

  boot.loader.grub.default = "saved";
}


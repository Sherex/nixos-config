{ config, lib, pkgs, ... }:

{
  imports = [
    ../systems/common.nix
    ../users/sherex.nix
    ../modules/gpu
    ../modules/hyprland
    ../modules/sound
    ../modules/sops
    ../modules/borg
    ../modules/vpn
    ../modules/kde-connect
  ];

  boot.loader.grub.default = "saved";
}


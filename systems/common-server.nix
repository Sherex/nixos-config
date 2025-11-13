{ config, lib, pkgs, ... }:

{
  imports = [
    ../systems/common.nix
    ../users/sherex-server.nix
    #../modules/sops
    #../modules/borg
  ];
}


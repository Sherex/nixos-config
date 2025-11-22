{ config, lib, pkgs, ... }:

{
  imports = [
    ../systems/common.nix
    ../users/sherex-server.nix
  ];
}


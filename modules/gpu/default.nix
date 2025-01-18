{ config, pkgs, lib, ... }:

{
  imports = [
    ./amd.nix
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    gpu-viewer
  ];
}


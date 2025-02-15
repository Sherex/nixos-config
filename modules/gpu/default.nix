{ config, pkgs, lib, ... }:

{
  imports = [
    ./amd.nix
    ./nvidia.nix
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    gpu-viewer
    clinfo
  ];
}


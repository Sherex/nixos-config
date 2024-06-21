{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];

  programs.steam = {
    enable = true;
  };
}


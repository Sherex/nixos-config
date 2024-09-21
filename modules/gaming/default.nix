{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];

  programs.steam = {
    enable = true;
  };

  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      discord
    ];
  };
}


{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ../users/common.nix
    ../modules/bash
    ../modules/neovim
    ../modules/git
  ];

  programs.tcpdump.enable = true;
  users.users.sherex = {
    linger = true;
    extraGroups = [ "pcap" ];
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
    ];
  };
}

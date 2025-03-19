{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      teams
    ];
  };
}


{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    home-manager.nixosModule
  ];

  home-manager.users.sherex = { pkgs, ... }: {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}


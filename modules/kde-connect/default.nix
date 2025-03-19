{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex = { pkgs, ... }: {
    services.kdeconnect = {
      enable = true;
    };
  };
}


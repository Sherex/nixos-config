{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex = { pkgs, ... }: {
    programs.i3status-rust = {
      enable = true;
    };

    xdg.configFile."i3status-rust/config.toml" = {
      source = ./config.toml;
    };
  };
}



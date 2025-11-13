{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ../users/common.nix
    ../modules/power-management
    ../modules/foot
    ../modules/qutebrowser
    ../modules/librewolf
    ../modules/email
    ../modules/rofi
    ../modules/i3status-rust
    ../modules/ssh
    ../modules/vscode
    ../modules/containerization
    ../modules/moonlight
  ];

  users.users.sherex = {
    extraGroups = [
      config.users.groups.input.name
    ];
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      httpie
      feh
      distrobox
    ];

    home.pointerCursor = {
      gtk.enable = true;
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 16;
    };

    gtk = {
      enable = true;

      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };

      font = {
        name = "Sans";
        size = 11;
      };
    };
    xdg = {
      enable = true;
      mimeApps = {
        enable = true;
        defaultApplications."x-scheme-handler/msteams" = [ "teams.desktop" ];
      };
    };
  };
}

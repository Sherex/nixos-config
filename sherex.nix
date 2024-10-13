{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    home-manager.nixosModule
    ./modules/power-management
    ./modules/bash
    ./modules/neovim
    ./modules/foot
    ./modules/qutebrowser
    ./modules/librewolf
    ./modules/email
    ./modules/rofi
    ./modules/i3status-rust
    ./modules/ssh
    ./modules/git
    ./modules/vscode
  ];

  # Install packages to /etc/profiles instead of ~/.nix-profile
  home-manager.useUserPackages = true;
  # Make home-manager use the global pkgs option
  home-manager.useGlobalPkgs = true;

  users.users.sherex = {
    isNormalUser = true;
    extraGroups = [
      config.users.groups.wheel.name
      config.users.groups.nix-allowed.name
    ];
    hashedPasswordFile = "/persistent/safe/sherex-password-hash";
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.stateVersion = "22.11";
    programs.home-manager.enable = true;
    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications."x-scheme-handler/msteams" = [ "teams.desktop" ];
    home.packages = with pkgs; [
      httpie
      unar
      feh
      numbat
      devbox
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
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
}

{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    home-manager.nixosModule
    ./modules/power-management
    ./modules/bash
    ./modules/neovim
    ./modules/foot
    ./modules/qutebrowser
    ./modules/chromium
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
    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications."x-scheme-handler/msteams" = [ "teams.desktop" ];
    home.packages = with pkgs; [
      httpie
      unar
      feh
      numbat
      devbox
    ];
    programs.home-manager.enable = true;
  };
}

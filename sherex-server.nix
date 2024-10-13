{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    home-manager.nixosModule
    ./modules/bash
    ./modules/neovim
    ./modules/git
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
    linger = true;
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      unar
      numbat
      devbox
    ];
    programs.home-manager.enable = true;
  };
}

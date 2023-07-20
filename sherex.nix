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
  ];

  # Install packages to /etc/profiles instead of ~/.nix-profile
  home-manager.useUserPackages = true;
  # Make home-manager use the global pkgs option
  home-manager.useGlobalPkgs = true;

  users.users.sherex = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      httpie
      unar
      teams
    ];
    programs.git = {
      enable = true;
      # TODO: Use variables for name and email
      userName = "Ingar Helgesen";
      userEmail = "ingar@i-h.no";
    };
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
      ];
    };
    programs.home-manager.enable = true;
  };
}

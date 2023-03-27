{ config, pkgs, lib, ... }:

{
  imports = [ <home-manager/nixos> ];

  # Install packages to /etc/profiles instead of ~/.nix-profile
  home-manager.useUserPackages = true;
  # Make home-manager use the global pkgs option
  home-manager.useGlobalPkgs = true;

  users.users.sherex = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      qutebrowser
    ];
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      httpie
    ];
    programs.bash.enable = true;
    programs.home-manager.enable = true;
  };
}

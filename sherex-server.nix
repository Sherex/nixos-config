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

  systemd.services.set-initial-user-password = {
    enable = true;
    description = "Sets the initial user password for sherex if it has no usable password";
    before = [ "getty.target" ];
    path = [ "/run/current-system/sw" ];
    script = ''
      # Check if the user has a usable password
      PASS_STATUS="$(passwd --status sherex | cut -d' ' -f2)"
      [[ $PASS_STATUS = 'P' ]] && exit 0

      echo this-is-temporary | passwd --stdin sherex
    '';
    wantedBy = [ "multi-user.target" ];
  };

  users.users.sherex = {
    isNormalUser = true;
    createHome = true;
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

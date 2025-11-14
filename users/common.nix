{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ../modules/bash
    ../modules/neovim
    ../modules/git
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

      echo this-is-temporary | passwd --expire --stdin sherex
    '';
    wantedBy = [ "multi-user.target" ];
  };

  users.users.sherex = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [
      config.users.groups.wheel.name
      config.users.groups.nix-allowed.name
      config.users.groups.nix-trusted.name
    ];
    hashedPasswordFile = "/persistent/safe/sherex-password-hash";
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.stateVersion = "22.11";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [
      unar
      numbat
      devbox
    ];
  };
}


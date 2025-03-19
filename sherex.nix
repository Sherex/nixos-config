{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
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
    ./modules/containerization
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
      config.users.groups.nix-trusted.name
      config.users.groups.input.name
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
      moonlight-qt
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

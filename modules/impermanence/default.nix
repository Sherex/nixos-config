{ config, pkgs, lib, ... }:

let
  persistent = {
    safe = "/persistent/safe";
    unsafe = "/persistent/unsafe";
  };
in
{
  # TODO: Create a generic function for persistance
  #       It should check if the path specified exists
  #       If not; it creates a symlink (check if source exists)
  #       If exists; it skips if symlink otherwise moves file/dir
  #       to persistance and creates a symlink
  environment.etc = {
    nixos.source = persistent.safe + "/etc/nixos";
    NIXOS.source = persistent.safe + "/etc/NIXOS";
    adjtime.source = persistent.safe + "/etc/adjtime";
    machine-id.source = persistent.safe + "/etc/machine-id";
    "wpa_supplicant.conf".source = persistent.safe + "/etc/wpa_supplicant.conf";
  };

  security.sudo.extraConfig = ''
    # Don't prompt the sudo lecture after each reboot
    Defaults lecture = never
  '';

  imports = [ <home-manager/nixos> ];

  home-manager.users.sherex = { pkgs, ... }: {
    # TODO: Use home-manager for user file persistance?
  };
}


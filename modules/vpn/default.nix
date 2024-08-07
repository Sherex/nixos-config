{ config, pkgs, lib, home-manager, ... }:

{
  services.mullvad-vpn.enable = true;

  environment.persistence."/persistent/safe" = {
    directories = [
      "/etc/mullvad-vpn"
    ];
  };

  environment.persistence."/persistent/unsafe" = {
    directories = [
      "/var/cache/mullvad-vpn"
    ];
  };
}


{ config, pkgs, lib, home-manager, ... }:

{
  services.pipewire = {
    enable = true;
    jack.enable = false;
    wireplumber.enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  home-manager.users.sherex = { pkgs, ... }: {
    services.easyeffects.enable = true;
    home.packages = with pkgs; [
      alsa-utils
    ];
  };
}


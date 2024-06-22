{ config, pkgs, lib, home-manager, ... }:

{
  sound = {
    mediaKeys.enable = true;
  };

  services.pipewire = {
    enable = true;
    jack.enable = false;
    wireplumber.enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  home-manager.users.sherex = { pkgs, ... }: {
    services.easyeffects.enable = true;
  };
}


{ config, pkgs, lib, home-manager, ... }:

{
  hardware.bluetooth.enable = true;

  home-manager.users.sherex = { pkgs, ... }: {
    # Handle media buttons on bluetooth devices using the MPRIS2 protocol
    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headset_buttons_to_control_media_player
    services.mpris-proxy.enable = true;

    home.packages = with pkgs; [
      bluetui
    ];
  };
}



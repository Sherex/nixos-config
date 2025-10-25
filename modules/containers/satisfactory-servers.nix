{ inputs, config, pkgs, lib,  ... }:

{
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.satisfactory = {
    autoStart = false;
    image = "wolveix/satisfactory-server:latest";
    ports = [
      "7777:7777/udp"
      "7777:7777/tcp"
    ];
    volumes = [
      "/srv/containers/satisfactory/container-data:/config"
    ];

    environment = {
      MAXPLAYERS = "10";
      PGID = "1000";
      PUID = "1000";
      ROOTLESS = "false";
      STEAMBETA = "false";
    };
  };

  # src: https://nixos.wiki/wiki/Podman

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Useful other development tools
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    #docker-compose # start group of containers for dev
    podman-compose # start group of containers for dev
  ];

  networking.firewall = {
    allowedTCPPorts = [ 7777 ];
    allowedUDPPorts = [ 7777 ];
  };
}


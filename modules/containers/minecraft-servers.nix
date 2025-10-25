{ inputs, config, pkgs, lib,  ... }:

{
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.all-the-mods-9 = {
    autoStart = false;
    image = "itzg/minecraft-server:java17";
    # tty = true;
    # stdin_open = true;
    # stop_grace_period = "1m";
    # restart = always;
    ports = [
      "25565:25565"
    ];
    #workdir = "/srv/containers/all-the-mods-9/";
    volumes = [
      # attach the relative directory 'data' to the container's /data path
      "/srv/containers/all-the-mods-9//container-data:/data:Z"
      "/srv/containers/all-the-mods-9//downloads:/downloads:Z"
    ];

    environment = {
      TZ = "Europe/Oslo";

      EULA = "TRUE";
      MAX_BUILD_HEIGHT = "1024";
      SPAWN_PROTECTION = "0";
      ALLOW_FLIGHT = "true";
      ENABLE_COMMAND_BLOCK = "true";
      #ENABLE_RCON = "false";

      #TYPE = "CUSTOM";
      VERSION = "1.20.1";
      INIT_MEMORY = "1G";
      MAX_MEMORY = "15G";
      USE_AIKAR_FLAGS = "true";
      TUNE_VIRTUALIZED = "true";
      #CUSTOM_SERVER = "/data/start.sh";
      #NEOFORGE_VERSION = "beta";

      #ENABLE_AUTOPAUSE = "FALSE"; # Doesn't work with rootless
      MAX_TICK_TIME = "-1";
      #AUTOPAUSE_TIMEOUT_INIT = "30";
      #AUTOPAUSE_TIMEOUT_EST = "1800";

      DEBUG_AUTOPAUSE = "true";
      DEBUG_AUTOSTOP = "true";

      RCON_CMDS_LAST_DISCONNECT = ''
        say Last disconnected
      '';

      #CF_API_KEY = "";
      #CF_PAGE_URL = "https://www.curseforge.com/minecraft/modpacks/bm-revelations-2/files/5715118";
      TYPE = "CURSEFORGE";
      CF_SERVER_MOD = "/downloads/server-files.zip";
      CF_DOWNLOADS_REPO = "/downloads";
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
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };
}


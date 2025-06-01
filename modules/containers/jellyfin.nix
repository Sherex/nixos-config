{ inputs, config, pkgs, lib,  ... }:

{
  virtualisation.oci-containers.containers.jellyfin = {
    # https://hub.docker.com/r/linuxserver/jellyfin/tags
    image = "linuxserver/jellyfin@sha256:70676df4e0ebce4438a6edddbaca2d0d0b8aa6bc45bbfdd9c6c42814a0f84b8c"; # :10.10.7
    ports = [
      "8096:8096/tcp"
      "8097:8097/tcp"
      # "7359:7359/udp"
      # "1900:1900/udp"
    ];
    volumes = [
      "/srv/containers/jellyfin/container-data/config:/config"
      "/srv/containers/jellyfin/container-data/cache:/cache"
      "/srv/containers/jellyfin/container-data/media:/media"
    ];
    devices = [
      "/dev/dri:/dev/dri"
      "nvidia.com/gpu=all"
    ];
    environment = {
      PUID = "700";
      PGID = "700";
      TZ = "Etc/UTC";
      #JELLYFIN_PublishedServerUrl = "https://jellyfin.i-h.no";
    };
    #user = "700:700";
    # extraOptions = [
    #   "--userns=keep-id"
    # ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 8096 8097 ];
    #allowedUDPPorts = [ 8096 8097 ];
  };
}


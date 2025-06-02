{ inputs, config, pkgs, lib,  ... }:

{
  # systemd.services.podman-haproxy.serviceConfig = {
  #   AmbientCapabilities = "CAP_NET_BIND_SERVICE";
  # };
  virtualisation.oci-containers.containers.haproxy = {
    # https://hub.docker.com/_/haproxy/tags
    image = "haproxy@sha256:fe54da647b73880b2f048c954b7c681ff6e69989162a42d12395447db176631f"; # :lts
    ports = [
      "80:80"
      "443:443"
    ];
    capabilities = {
      CAP_NET_BIND_SERVICE = true;
    };
    volumes = [
      "/srv/containers/haproxy/container-data/config:/usr/local/etc/haproxy:ro"
    ];
    environment = {
      PUID = "700";
      PGID = "700";
      TZ = "Etc/UTC";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 80 443 ];
  };
}


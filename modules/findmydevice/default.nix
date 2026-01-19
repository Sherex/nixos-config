{ config, pkgs, lib, ... }:

let
  root_domain = "i-h.no";
  http_socket = "/run/fmd/fmd.sock";
in {
  # The actual FMD service is running in a container OOB for now (skrekk og gru! :o)
  # TODO: Create a service for the FMD server. The server itself is written in Go so should be fairly easy.

  services.nginx.virtualHosts."fmd.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://unix:${http_socket}";
    };
  };
}


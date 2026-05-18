{ config, pkgs, lib, ... }:

let
  root_domain = "i-h.no";
in {
  # The actual Qui service is running on Nixtron as a container for the time being.

  services.nginx.virtualHosts."qui.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://100.70.0.7:8082";
      extraConfig = ''
        allow 127.0.0.1;
        allow 100.70.0.0/16; # Tailscale
        deny all;
      '';
    };
  };
}

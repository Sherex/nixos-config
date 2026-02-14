{ config, pkgs, lib, ... }:

let
  root_domain = "i-h.no";
in {
  # The actual Home Assistant service is running on Nixxer as a container for the time being.

  services.nginx.virtualHosts."hass.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      extraConfig = ''
        # Set proxy_pass using variable to force runtime DNS lookup
        # The nixxer hostname is only resolvable when Headscale is
        # running, which is only reachable through Nginx...
        # (circular dependency)
        set $backend "http://100.70.0.3:8100";
        proxy_pass $backend;

        allow 127.0.0.1;
        allow 100.70.0.0/16; # Tailscale
        deny all;
        proxy_ssl_verify off;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };

}


{ config, pkgs, lib, ... }:

let
  root_domain = "i-h.no";
  proxyPassDynamic = backend: ''
    # Set proxy_pass using variable to force runtime DNS lookup
    # The nixtron hostname is only resolvable when Headscale is
    # running, which is only reachable through Nginx...
    # (circular dependency)
    set $backend "${backend}";
    proxy_pass $backend;

    proxy_ssl_verify off;
  '';
in {
  # The actual Home Assistant service is running on Nixxer as a container for the time being.

  services.nginx.virtualHosts."hass.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://100.70.0.3:8100";
      extraConfig = ''
        allow 127.0.0.1;
        allow 100.70.0.0/16; # Tailscale
        deny all;
      '';
    };
  };

  services.nginx.virtualHosts."zigbee2mqtt.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://100.70.0.3:10201";
      extraConfig = ''
        allow 127.0.0.1;
        allow 100.70.0.0/16; # Tailscale
        deny all;
      '';
    };
  };

  services.nginx.virtualHosts."esphome.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://100.70.0.3:6052";
      extraConfig = ''
        allow 127.0.0.1;
        allow 100.70.0.0/16; # Tailscale
        deny all;
      '';
    };
  };
}


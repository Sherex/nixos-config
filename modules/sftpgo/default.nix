{ config, pkgs, lib, ... }:

let
  root_domain = "i-h.no";
in {
  # The actual SFTPGo service is running on Nixtron for the time being.

  services.nginx.virtualHosts."files.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      extraConfig = ''
        # Set proxy_pass using variable to force runtime DNS lookup
        # The nixtron hostname is only resolvable when Headscale is
        # running, which is only reachable through Nginx...
        # (circular dependency)
        set $backend "https://nixtron:8081";
        proxy_pass $backend;

        allow 127.0.0.1;
        allow 100.70.0.0/16; # Tailscale
        #allow 1.2.3.4/32; # Useful if devices needs access before Tailscale is setup
        deny all;
        proxy_ssl_verify off;
      '';
    };
  };

}


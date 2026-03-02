{ config, pkgs, lib, ... }:

let
  root_domain = "i-h.no";
  allowOnlyTailnet = ''
    allow 127.0.0.1;
    allow 100.70.0.0/16; # Tailscale
    #allow 1.2.3.4/32; # Useful if devices needs access before Tailscale is setup
    deny all;
  '';
in {
  # The actual service is running on Nixxy for the time being.
  services.nginx.virtualHosts."mat.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:8889";
      extraConfig = ''
        ${allowOnlyTailnet}
        client_max_body_size 0;
      '';
    };
  };
}


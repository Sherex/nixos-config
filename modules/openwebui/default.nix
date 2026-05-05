{ config, pkgs, lib, ... }:

let
  root_domain = "i-h.no";
  allowOnlyTailnet = ''
    allow 127.0.0.1;
    allow ${config.services.headscale.settings.prefixes.v4}; # Tailscale
    deny all;
  '';
in {
  services.nginx.virtualHosts."chat.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://localhost:10030";
      extraConfig = ''
        ${allowOnlyTailnet}
        client_max_body_size 0;
      '';
    };
  };
}


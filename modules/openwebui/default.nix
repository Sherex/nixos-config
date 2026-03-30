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
      extraConfig = ''
        ${proxyPassDynamic "http://localhost:10030"}
        ${allowOnlyTailnet}
        client_max_body_size 0;
      '';
    };
  };
}


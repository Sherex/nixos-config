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
    allow 100.70.0.0/16; # Tailscale
    #allow 1.2.3.4/32; # Useful if devices needs access before Tailscale is setup
    deny all;
  '';
in {
  # The actual SFTPGo service is running on Nixtron for the time being.
  services.nginx.virtualHosts."files.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      extraConfig = ''
        ${proxyPassDynamic "https://nixtron.i.i-h.no:8080"}
        ${allowOnlyTailnet}
        client_max_body_size 0;
      '';
    };
    locations."/web/client/pubshares/" = {
      extraConfig = ''
        ${proxyPassDynamic "https://nixtron.i.i-h.no:8080"}
        allow all;
        client_max_body_size 0;
      '';
    };
    locations."/static/" = {
      extraConfig = ''
        ${proxyPassDynamic "https://nixtron.i.i-h.no:8080"}
        allow all;
      '';
    };
  };
  services.nginx.virtualHosts."webdav.${root_domain}" = {
    useACMEHost = "${root_domain}";
    forceSSL = true;
    locations."/" = {
      extraConfig = ''
        ${proxyPassDynamic "https://nixtron.i.i-h.no:8081"}
        ${allowOnlyTailnet}
        client_max_body_size 0;

        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_request_buffering off;
        proxy_buffering off;

        proxy_read_timeout 900;
        proxy_send_timeout 900;
        proxy_connect_timeout 60;

        proxy_cache_bypass 1;
        proxy_no_cache 1;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
      '';
    };
  };
}


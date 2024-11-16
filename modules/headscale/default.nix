{ inputs, config, pkgs, lib,  ... }:

let
  domain = "localhost";
in {
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        server_url = "http://${domain}";
        dns = {
          magic_dns = false;
          baseDomain = "localhost";
        };
        logtail.enabled = false;
      };
    };

    nginx.virtualHosts.${domain} = {
      forceSSL = false;
      enableACME = false;
      locations."/" = {
        proxyPass =
          "http://localhost:${toString config.services.headscale.port}";
        proxyWebsockets = true;
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];
}


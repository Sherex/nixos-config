{ inputs, config, pkgs, lib,  ... }:

let
  domain = "nixxy.i-h.no";
  derpPort = 8558;
in {
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        unix_socket_permission = "0770";
        server_url = "https://${domain}";
        prefixes = {
          v4 = "100.70.0.0/16";
        };
        dns = {
          magic_dns = true;
          base_domain = "i.i-h.no";
          nameservers = { "global" = [ "1.1.1.1" ]; };
        };
        logtail.enabled = false;
        log.level = "info";
        derp.server = {
          enabled = true;
          region_id = 999;
          stun_listen_addr = "${config.services.headscale.address}:${toString derpPort}";
        };
        policy = {
          mode = "file";
          path = ./headscale-acl.jsonc;
        };
      };
    };

    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass =
          "http://localhost:${toString config.services.headscale.port}";
        proxyWebsockets = true;
      };
    };

    # TODO: Extract nginx to its own module
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ derpPort ];

  environment.systemPackages = [ config.services.headscale.package ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ingar+acme@i-h.no";
    };
  };

  users.users.sherex = {
    extraGroups = [
      config.users.groups.headscale.name
    ];
  };

  environment.persistence."/persistent/safe" = {
    directories = [
      "/var/lib/headscale"
    ];
  };
}


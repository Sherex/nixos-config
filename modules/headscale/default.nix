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
          nameservers = { "global" = [ "10.1.0.1" "1.1.1.1" ]; };
          override_local_dns = true;
        };
        logtail.enabled = false;
        log.level = "info";
        derp = {
          server = {
            enabled = true;
            region_id = 999;
            stun_listen_addr = "${config.services.headscale.address}:${toString derpPort}";
          };
          urls = []; # Disable use of Tailscales DERP servers
        };
        policy = {
          mode = "file";
          path = ./headscale-acl.jsonc;
        };
      };
    };

    nginx.virtualHosts.${domain} = {
      serverAliases = [ "nixxy.i-h.no" ];
      useACMEHost = "i-h.no";
      forceSSL = true;
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
  users.users.nginx.extraGroups = ["acme"]; # Give Nginx rights to access certs

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ derpPort ];

  environment.systemPackages = [ config.services.headscale.package ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ingar+acme@i-h.no";
      dnsProvider = "luadns";
      dnsResolver = "1.1.1.1:53";
      # TODO: Use SOPS-nix for acme secrets
      environmentFile = "/persistent/safe/acme-secrets.env";
      webroot = null; # Use DNS challenge
    };
    certs."i-h.no" = {
      extraDomainNames = ["*.i-h.no"];
    };
    certs."s3.i-h.no" = {
      extraDomainNames = [ "*.s3.i-h.no" "web.i-h.no" "*.web.i-h.no"];
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


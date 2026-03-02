{ inputs, config, pkgs, lib,  ... }:

let
  domain = "vpn.i-h.no";
  derpPort = 8558;
in {
  services = {
    headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 28080;
      settings = {
        unix_socket_permission = "0770";
        server_url = "https://${domain}";
        prefixes = {
          v4 = "100.70.0.0/16";
        };
        dns = {
          magic_dns = true;
          base_domain = "i.i-h.no";
          nameservers = { "global" = [ "100.100.100.100" "10.1.0.1" "1.1.1.1" ]; };
          override_local_dns = true;
          extra_records_path = "/var/lib/headscale/dns-records.json";
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
          "http://127.0.0.1:${toString config.services.headscale.port}";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [ derpPort ];

  environment.systemPackages = [ config.services.headscale.package ];

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


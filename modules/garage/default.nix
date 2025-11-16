{ config, pkgs, lib, ... }:

let
  service_data_path = "/srv/services/garage";
  root_domain = "i-h.no";
  s3_web_socket = "/run/garage/s3-web.http.sock";
  s3_api_socket = "/run/garage/s3-api.http.sock";
  admin_socket = "/run/garage/admin.http.sock";
in {
  services = {
    garage = {
      enable = true;
      package = pkgs.garage_2;
      # Ref: https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration/
      settings = {
        data_dir = "${service_data_path}/data";
        metadata_dir = "${service_data_path}/metadata";
        db_engine = "sqlite";
        allow_world_readable_secrets = true; # Not world readable, but not 400 either

        rpc_bind_addr = "[::]:3901";
        rpc_secret_file =  "/persistent/safe/garage-rpc.token";
        replication_factor = 1;

        s3_api = {
          api_bind_addr = "${s3_api_socket}";
          s3_region = "garage";
          root_domain = ".s3.${root_domain}";
        };

        s3_web = {
          bind_addr = "${s3_web_socket}";
          root_domain = ".web.${root_domain}";
        };
        admin = {
          api_bind_addr = "${admin_socket}";
          # TODO: Use SOPS secrets
          metrics_token_file = "/persistent/safe/garage-metrics.token";
          admin_token_file = "/persistent/safe/garage-admin.token";
        };
      };
    };
    nginx.virtualHosts."s3.${root_domain}" = {
      serverAliases = ["*.s3.${root_domain}"];
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS challenge
      locations."/" = {
        proxyPass = "http://unix:${s3_api_socket}";
        extraConfig = ''
          if ($request_method = OPTIONS) { return 204; }
        '';
      };
      extraConfig = ''
        if ($http_origin = ""){
          set $http_origin "*";
        }
        proxy_hide_header Access-Control-Allow-Origin;
        add_header 'Access-Control-Allow-Origin'  $http_origin always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS, HEAD' always;
        add_header 'Access-Control-Allow-Headers' 'authorization,x-amz-content-sha256,x-amz-date,x-amz-user-agent' always;
      '';
    };
    nginx.virtualHosts."web.${root_domain}" = {
      serverAliases = ["*.web.${root_domain}"];
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS challenge
      locations."/" = {
        proxyPass = "http://unix:${s3_web_socket}";
      };
    };
    nginx.virtualHosts."s3-admin.${root_domain}" = {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null; # Use DNS challenge
      locations."/" = {
        proxyPass = "http://unix:${admin_socket}";
        extraConfig = ''
          allow 127.0.0.1;
          allow 100.70.0.0/16; # Tailscale
          deny all;
        '';
      };
    };
  };

  users = {
    groups.garage = { };
    users.garage = {
      isSystemUser = true;
      group = "garage";
    };
  };
  # Allow nginx access to Garages HTTP sockets
  users.users.nginx.extraGroups = [ config.users.groups.garage.name ];

  systemd.services.garage = {
    after = [ "systemd-tmpfiles-resetup.service" ];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "garage";
      Group = "garage";
      ReadWritePaths = [ "${dirOf s3_api_socket}" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${service_data_path} 0750 garage garage -"
    "d ${service_data_path}/data 0750 garage garage -"
    "d ${service_data_path}/metadata 0750 garage garage -"
    "d ${dirOf s3_api_socket} 0750 garage garage -"
  ];

  environment.persistence."/persistent/safe" = {
    directories = [
      {
        directory = "${service_data_path}/data";
        user = config.systemd.services.garage.serviceConfig.User;
        group = config.systemd.services.garage.serviceConfig.Group;
        mode = "u=rwx,g=rx,o=";
      }
      {
        directory = "${service_data_path}/metadata";
        user = config.systemd.services.garage.serviceConfig.User;
        group = config.systemd.services.garage.serviceConfig.Group;
        mode = "u=rwx,g=rx,o=";
      }
    ];
  };
}


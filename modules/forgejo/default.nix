{
  config,
  pkgs,
  lib,
  ...
}:

let
  name = "forgejo";
  cfg = config.${name};
  root_domain = "i-h.no";
  domain = "git.${root_domain}";
  allowOnlyTailnet = ''
    allow 127.0.0.1;
    allow 100.70.0.0/16; # Tailscale
    deny all;
  '';
in
{
  imports = [
    ./runner.nix
  ];
  options.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    # environment.persistence."/persistent/safe" = {
    #   directories = [
    #     # Expects service to use DynamicUser
    #     {
    #       directory = "/var/lib/private/${config.systemd.services.forgejo.serviceConfig.StateDirectory}";
    #       user = "nobody";
    #       group = "nogroup";
    #       mode = "u=rwx,g=,o=";
    #     }
    #   ];
    # };

    services.forgejo = {
      enable = true;
      dump = {
        enable = true;
        # Tar is selcted with no compression as my fs already has good compression using zstd.
        # And more importantly this will also allow Borg to dedupe the archive during backup so that one small change in a file won't result in all chunks of the archive changing.
        type = "tar";
        interval = "01:00";
        age = "3d";
      };
      settings = {
        server = {
          APP_NAME = "Git IH";
          PROTOCOL = "http+unix";
          DOMAIN = domain;
          ROOT_URL = "https://${domain}";
        };
        repository = {
          DEFAULT_REPO_UNITS = "repo.code,repo.releases";
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        metrics = {
          ENABLED = true;
        };
        "git.timeout" = {
          MIGRATE = 60 * 60 * 2;
        };
        session = {
          COOKIE_SECURE = true;
        };
      };
    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "${root_domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}";
        extraConfig = ''
          client_max_body_size 1g;
        '';
      };
      locations."/metrics" = {
        proxyPass = "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}";
        extraConfig = allowOnlyTailnet;
      };
    };

    services.victoriametrics.prometheusConfig.scrape_configs = [
      {
        job_name = "forgejo";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [ config.services.forgejo.settings.server.ROOT_URL ];
          }
        ];
      }
    ];
  };
}

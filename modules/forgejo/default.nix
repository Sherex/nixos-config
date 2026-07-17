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
in
{
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
      settings = {
        server = {
          PROTOCOL = "http+unix";
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        metrics = {
          ENABLED = true;
        };
      };
    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "${root_domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}";
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:
let
  name = "vaultwarden";
  cfg = config.${name};
  service = config.services.vaultwarden;
  systemdService = config.systemd.services.vaultwarden;
  root_domain = "i-h.no";
  domain = "${name}.${root_domain}";
  allowOnlyTailnet = ''
    allow 127.0.0.1;
    allow 100.70.0.0/16; # Tailscale
    deny all;
  '';
in
{
  options.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    environment.persistence."/persistent/safe" = {
      directories = [
        # Expects service to use DynamicUser
        {
          directory = "/var/lib/${systemdService.serviceConfig.StateDirectory}";
          user = systemdService.serviceConfig.User;
          group = systemdService.serviceConfig.Group;
          mode = "u=rwx,g=,o=";
        }
      ];
    };

    services.vaultwarden = {
      enable = true;
      inherit domain;
      dbBackend = "sqlite";
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "${root_domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${service.config.ROCKET_ADDRESS}:${toString service.config.ROCKET_PORT}";
        extraConfig = ''
          ${allowOnlyTailnet}
        '';
      };
    };
  };
}

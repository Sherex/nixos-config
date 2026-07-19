{
  config,
  pkgs,
  lib,
  ...
}:
let
  name = "victorialogs";
  cfg = config.${name};
  root_domain = "i-h.no";
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
          directory = "/var/lib/private/${config.systemd.services.victorialogs.serviceConfig.StateDirectory}";
          user = "nobody";
          group = "nogroup";
          mode = "u=rwx,g=,o=";
        }
      ];
    };

    assertions = [
      {
        assertion = !!config.systemd.services.victorialogs.serviceConfig.DynamicUser;
        message = "Current persistance directory configuration for Victorialogs expects victorialogs DynamicUser service setting to be enabled";
      }
    ];

    services.victorialogs = {
      enable = true;
      listenAddress = "127.0.0.1:9428";
      extraOptions = [
        "-journald.streamFields=_SYSTEMD_UNIT,_HOSTNAME"
        "-journald.includeEntryMetadata"
        "-retentionPeriod=2y"
      ];
    };

    services.nginx.virtualHosts."victorialogs.${root_domain}" = {
      useACMEHost = "${root_domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${config.services.victorialogs.listenAddress}";
        extraConfig = ''
          ${allowOnlyTailnet}
        '';
      };
    };

    services.journald.upload = {
      enable = true;
      settings.Upload = {
        URL = "http://${config.services.victorialogs.listenAddress}/insert/journald";
      };
    };

    systemd.services.systemd-journal-upload = {
      after = [ "victorialogs.service" ];
      wants = [ "victorialogs.service" ];
    };

    services.grafana = {
      settings.plugins.allow_loading_unsigned_plugins = "victoriametrics-logs-datasource";
      declarativePlugins = with pkgs.grafanaPlugins; [
        victoriametrics-logs-datasource
      ];
      provision.datasources.settings.datasources = [
        {
          name = "VictoriaLogs";
          type = "victoriametrics-logs-datasource";
          url = "http://${config.services.victorialogs.listenAddress}";
        }
      ];
    };
  };
}

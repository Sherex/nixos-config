{ config, pkgs, lib, ... }:

let
  name = "observability";
  cfg = config.${name};
  root_domain = "i-h.no";
  allowOnlyTailnet = ''
    allow 127.0.0.1;
    allow 100.70.0.0/16; # Tailscale
    allow 92.220.25.0/24; # Heddal
    #allow 1.2.3.4/32; # Useful if devices needs access before Tailscale is setup
    deny all;
  '';
  grafana = {
    username = "grafana";
    data_path = "/srv/services/grafana";
  };
in
{
  options.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    environment.persistence."/persistent/safe" = {
      directories = [
        {
          directory = grafana.data_path;
          user = grafana.username;
          group = grafana.username;
          mode = "u=rwx,g=,o=";
        }
        # Expects service to use DynamicUser
        {
          directory = "/var/lib/private/${config.systemd.services.victoriametrics.serviceConfig.StateDirectory}";
          user = "nobody";
          group = "nogroup";
          mode = "u=rwx,g=,o=";
        }
      ];
    };

    assertions = [
      {
        assertion = !!config.systemd.services.victoriametrics.serviceConfig.DynamicUser;
        message = "Current peristence directory configuration for Victoriametrics expects victoriametrics DynamicUser service setting to be enabled";
      }
    ];

    services.grafana = {
      enable = true;
      dataDir = grafana.data_path;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 8400;
          root_url = "https://grafana.${root_domain}";
          serve_from_sub_path = true;
        };
        security = {
          secret_key = "jaddanotsecure";
          admin_user = "admin";
          admin_password = "admin";
        };
        auth = {
          disable_login_form = false;
        };
      };

      provision = {
        enable = true;

        datasources.settings.datasources = [
          {
            name = "VictoriaMetrics";
            type = "prometheus";
            url = "http://${config.services.victoriametrics.listenAddress}";
            isDefault = true;
          }
        ];
      };
    };

    services.victoriametrics = {
      enable = true;
      listenAddress = "127.0.0.1:8428";
      retentionPeriod = "100y";
    };

    services.victoriametrics.prometheusConfig.scrape_configs = [
      {
        job_name = "victoriametrics";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [ config.services.victoriametrics.listenAddress ];
          }
        ];
      }
      {
        job_name = "node";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "fail2ban";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.fail2ban.port}" ];
          }
        ];
      }
      {
        job_name = "nginx";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}" ];
          }
        ];
      }
      {
        job_name = "blackbox";
        metrics_path = "/probe";
        params = {
          module = [ "http_2xx" ];
        };
        static_configs = [
          {
            targets = [
              "https://i-h.no"
              "https://helgesn.com"
              "https://ihdata.no"
              "https://karlsentertainment.no"
            ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:${toString config.services.prometheus.exporters.blackbox.port}";
          }
        ];
      }
      {
        job_name = "blackbox_exporter";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.blackbox.port}" ];
          }
        ];
      }
    ];
    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" "processes" ];
        port = 9002;
      };
      fail2ban = {
        enable = true;
        port = 9191; # NOTE: This option was not respected when testing other ports
      };
      nginx = {
        enable = true;
        port = 9004;
      };
      blackbox = {
        enable = true;
        port = 9005;
        configFile = pkgs.writeText "blackbox.yaml" (builtins.toJSON {
          # Ref: https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md
          # Src: https://github.com/prometheus/blackbox_exporter/blob/master/blackbox.yml
          modules = {
            http_2xx = {
              prober = "http";
              http = {
                preferred_ip_protocol = "ip4";
              };
            };
            http_post_2xx = {
              prober = "http";
              http = {
                method = "POST";
              };
            };
            tcp_connect = {
              prober = "tcp";
            };
            pop3s_banner = {
              prober = "tcp";
              tcp = {
                query_response = [
                  { expect = "^+OK"; }
                ];
                tls = true;
                tls_config = {
                  insecure_skip_verify = false;
                };
              };
            };
            grpc = {
              prober = "grpc";
              grpc = {
                tls = true;
                preferred_ip_protocol = "ip4";
              };
            };
            grpc_plain = {
              prober = "grpc";
              grpc = {
                tls = false;
                service = "service1";
              };
            };
            ssh_banner = {
              prober = "tcp";
              tcp = {
                query_response = [
                  { expect = "^SSH-2.0-"; }
                  { send = "SSH-2.0-blackbox-ssh-check"; }
                ];
              };
            };
            ssh_banner_extract = {
              prober = "tcp";
              timeout = "5s";
              tcp = {
                query_response = [
                  {
                    expect = "^SSH-2.0-([^ -]+)(?: (.*))?$";
                    labels = [
                      { name = "ssh_version"; value = "\${1}"; } # NOTE: The \ escapes the would-be Nix expression ${} and strips it from the result
                      { name = "ssh_comments"; value = "\${2}"; }
                    ];
                  }
                ];
              };
            };
            icmp = {
              prober = "icmp";
            };
            icmp_ttl5 = {
              prober = "icmp";
              timeout = "5s";
              icmp = {
                ttl = 5;
              };
            };
            websocket = {
              prober = "websocket";
            };
            http_3xx = {
              prober = "http";
              http = {
                preferred_ip_protocol = "ip4";
                enable_http3 = true;
                enable_http2 = false;
                valid_http_versions = [ "HTTP/3.0" ];
              };
            };
          };
        });
      };
    };

    services.nginx.virtualHosts."victoriametrics.${root_domain}" = {
      useACMEHost = "${root_domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${config.services.victoriametrics.listenAddress}";
        extraConfig = ''
          ${allowOnlyTailnet}
        '';
      };
    };
    services.nginx.virtualHosts."grafana.${root_domain}" = {
      useACMEHost = "${root_domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        extraConfig = ''
          ${allowOnlyTailnet}
        '';
      };
    };
  };
}

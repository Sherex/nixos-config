{ inputs, config, pkgs, lib,  ... }:

{
  services = {
    nginx = {
      enable = true;
      statusPage = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      resolver.addresses = [ "127.0.0.53" ];
      # recommendedProxySettings sets:
      # Host $host;
      # X-Real-IP $remote_addr;
      # X-Forwarded-For $proxy_add_x_forwarded_for;
      # X-Forwarded-Proto $scheme;
      # X-Forwarded-Host $host;
      # X-Forwarded-Server $hostname;

      appendHttpConfig = ''
        log_format json_full escape=json '{'
          '"connection": "$connection", '
          '"connection_requests": "$connection_requests", '
          '"remote_port": "$remote_port", '
          '"remote_addr": "$remote_addr", '
          '"request_uri": "$request_uri", '
          '"request_id": "$request_id", '
          '"request_length": "$request_length", '
          '"request_time": "$request_time", '
          '"request_method": "$request_method", '
          '"server_protocol": "$server_protocol", '
          '"nginx_host": "$host", '
          '"nginx_status": "$status", '
          '"body_bytes_sent": "$body_bytes_sent", '
          '"bytes_sent": "$bytes_sent", '
          '"http_user_agent": "$http_user_agent", '
          '"http_host": "$http_host", '
          '"ssl_protocol": "$ssl_protocol", '
          '"scheme": "$scheme", '
          '"gzip_ratio": "$gzip_ratio", '
          '"timestamp": "$time_iso8601", '
          '"http_referer": "$http_referer", '
          '"http_x_forwarded_for": "$http_x_forwarded_for", '
          '"upstream_addr": "$upstream_addr", '
          '"upstream_status": "$upstream_status", '
          '"upstream_connect_time": "$upstream_connect_time", '
          '"upstream_response_time": "$upstream_response_time", '
          '"ssl_cipher": "$ssl_cipher", '
          '"ssl_session_reused": "$ssl_session_reused", '
          '"message": "$request_method $scheme://$host$request_uri - $status - $remote_addr - $request_time s" '
        '}';

        access_log /var/log/nginx/access.log json_full;
      '';
    };
  };
  users.users.nginx.extraGroups = ["acme"]; # Give Nginx rights to access certs

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ ];

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
    certs."ihdata.no" = {
      extraDomainNames = ["*.ihdata.no"];
    };
    certs."helgesn.com" = {
      extraDomainNames = ["*.helgesn.com"];
    };
  };

  services.nginx.virtualHosts."ihdata.no" = {
    useACMEHost = "ihdata.no";
    forceSSL = true;
    locations."/".return = "302 https://i-h.no$request_uri";
  };

  services.nginx.virtualHosts."helgesn.com" = {
    useACMEHost = "helgesn.com";
    forceSSL = true;
    locations."/".return = "301 https://i-h.no$request_uri";
  };

  environment.persistence."/persistent/safe" = {
    directories = [
      "/var/lib/acme"
    ];
  };

  systemd.services.vector.serviceConfig.SupplementaryGroups = [ "nginx" ];
  services.vector.settings = {
    sources.nginx_logs = {
      type = "file";
      include = [
        "/var/log/nginx/access.log"
      ];
    };

    transforms.parse_nginx = {
      type = "remap";
      inputs = [ "nginx_logs" ];
      source = ''
        parsed = parse_json!(.message)

        del(.message)
        . = parsed

        .connection               = to_int(.connection) ?? null
        .connection_requests      = to_int(.connection_requests) ?? null
        .remote_port              = to_int(.remote_port) ?? null
        .request_length           = to_int(.request_length) ?? 0
        .request_time             = to_float(.request_time) ?? 0.0
        .nginx_status             = to_int(.nginx_status) ?? null
        .body_bytes_sent          = to_int(.body_bytes_sent) ?? 0
        .bytes_sent               = to_int(.bytes_sent) ?? 0
        .upstream_addr            = to_float(.upstream_addr) ?? 0.0
        .upstream_status          = to_int(.upstream_status) ?? null
        .upstream_connect_time    = to_float(.upstream_connect_time) ?? 0.0
        .upstream_response_time   = to_float(.upstream_response_time) ?? 0.0

        # Handle gzip ratio specifically. Only convert to float if it's an actual number.
        if .gzip_ratio == "-" || .gzip_ratio == null {
            del(.gzip_ratio)
        } else {
            .gzip_ratio = to_float(.gzip_ratio) ?? null
        }

        # Assign log level
        code = to_int(.nginx_status)
        .level = if code >= 500 { "error" }
          else if code >= 400 { "warn" }
          else if code >= 200 { "info" }
          else if code >= 100 { "debug" }
          else { "unknown" }
      '';
    };

    sinks.vlogs = {
      type = "http";
      inputs = [ "parse_nginx" ];
      uri = "http://127.0.0.1:9428/insert/jsonline?_stream_fields=nginx_host,request_method,request_status&_msg_field=message&_time_field=timestamp";
      # compression = "gzip";

      encoding = {
        codec = "json";
      };

      framing = {
        method = "newline_delimited";
      };

      healthcheck = {
        enabled = false;
      };
    };
  };
}


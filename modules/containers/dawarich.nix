{ inputs, config, pkgs, lib,  ... }:

{
  # virtualisation.oci-containers.containers.dawarich = {
  #   # https://hub.docker.com/r/freikin/dawarich/tags
  #   image = "freikin/dawarich@sha256:608fb06afb06d996199bd409b6eb521d5ac176561ab271c73e58fc5b04dd5d5b"; # :0.30.9
  #   ports = [
  #     "3000:3000"
  #   ];
  #   volumes = [
  #     "/srv/containers/haproxy/container-data/config:/usr/local/etc/haproxy:ro"
  #   ];
  #   environment = {
  #     PUID = "700";
  #     PGID = "700";
  #     TZ = "Etc/UTC";
  #   };
  # };

  virtualisation.oci-containers = {
    containers = {
      dawarich_redis = {
        # image + simple command entry
        image = "redis:7.4-alpine";
        cmd = [ "redis-server" ];

        # host -> container mounts (use absolute host paths)
        volumes = [
          "/srv/containers/dawarich/container-data/shared:/data"
        ];

        # ask podman to mark the systemd unit ready only after container healthcheck passes
        podman = { sdnotify = "healthy"; };

        # Docker/Podman health flags — simplified to avoid quoting pain in Nix
        extraOptions = [
          "--health-cmd=redis-cli --raw incr ping"
          "--health-interval=10s"
          "--health-retries=5"
          "--health-start-period=30s"
          "--health-timeout=10s"
        ];
      };

      dawarich_db = {
        image = "postgis/postgis:17-3.5-alpine";

        # increase shm size (Docker/Podman flag)
        extraOptions = [
          "--shm-size=1g"

          # simple healthcheck via pg_isready
          "--health-cmd=pg_isready -U postgres -d dawarich"
          "--health-interval=10s"
          "--health-retries=5"
          "--health-start-period=30s"
          "--health-timeout=10s"
        ];

        volumes = [
          "/srv/containers/dawarich/container-data/db-data:/var/lib/postgresql/data"
          "/srv/containers/dawarich/container-data/shared:/var/shared"
        ];

        environment = {
          POSTGRES_USER     = "postgres";
          POSTGRES_PASSWORD = "sGu7!fhcOsXzua@B";
          POSTGRES_DB       = "dawarich";
        };

        podman = { sdnotify = "healthy"; };
      };

      dawarich_app = {
        image = "freikin/dawarich:latest";

        entrypoint = "web-entrypoint.sh";
        cmd = [ "bin/rails" "server" "-p" "3000" "-b" "::" ];

        volumes = [
          "/srv/containers/dawarich/container-data/public:/var/app/public"
          "/srv/containers/dawarich/container-data/watched:/var/app/tmp/imports/watched"
          "/srv/containers/dawarich/container-data/storage:/var/app/storage"
          "/srv/containers/dawarich/container-data/db-data:/dawarich_db_data"
        ];

        ports = [ "3000:3000" ];

        # runtime environment
        environment = {
          RAILS_ENV                         = "development";
          REDIS_URL                         = "redis://dawarich_redis:6379";
          DATABASE_HOST                     = "dawarich_db";
          DATABASE_USERNAME                 = "postgres";
          DATABASE_PASSWORD                 = "sGu7!fhcOsXzua@B";
          DATABASE_NAME                     = "dawarich";
          MIN_MINUTES_SPENT_IN_CITY         = "60";
          APPLICATION_HOSTS                 = "localhost,nixxer,dawarich_app,dawarich.i-h.no";
          TIME_ZONE                         = "Europe/Oslo";
          APPLICATION_PROTOCOL              = "http";
          PROMETHEUS_EXPORTER_ENABLED       = "false";
          PROMETHEUS_EXPORTER_HOST          = "0.0.0.0";
          PROMETHEUS_EXPORTER_PORT          = "9394";
          SELF_HOSTED                       = "true";
          STORE_GEODATA                     = "true";
          PHOTON_API_HOST                   = "photon.koalasec.org";
          PHOTON_API_USE_HTTPS              = "true";
        };

        # the compose file waits for db+redis to be healthy before starting the app
        dependsOn = [ "dawarich_db" "dawarich_redis" ];

        # healthcheck: simplified (uses wget + grep 'ok' to keep quoting manageable)
        extraOptions = [
          "--health-cmd=sh -c 'wget -qO - http://127.0.0.1:3000/api/v1/health | grep -q ok'"
          "--health-interval=10s"
          "--health-retries=30"
          "--health-start-period=30s"
          "--health-timeout=10s"
        ];
      };

      dawarich_sidekiq = {
        image = "freikin/dawarich:latest";

        entrypoint = "sidekiq-entrypoint.sh";
        cmd = [ "sidekiq" ];

        volumes = [
          "/srv/containers/dawarich/container-data/public:/var/app/public"
          "/srv/containers/dawarich/container-data/watched:/var/app/tmp/imports/watched"
          "/srv/containers/dawarich/container-data/storage:/var/app/storage"
        ];

        environment = {
          RAILS_ENV                                 = "development";
          REDIS_URL                                 = "redis://dawarich_redis:6379";
          DATABASE_HOST                             = "dawarich_db";
          DATABASE_USERNAME                         = "postgres";
          DATABASE_PASSWORD                         = "sGu7!fhcOsXzua@B";
          DATABASE_NAME                             = "dawarich";
          APPLICATION_HOSTS                         = "localhost";
          BACKGROUND_PROCESSING_CONCURRENCY         = "10";
          APPLICATION_PROTOCOL                      = "http";
          PROMETHEUS_EXPORTER_ENABLED               = "false";
          PROMETHEUS_EXPORTER_HOST                  = "dawarich_app";
          PROMETHEUS_EXPORTER_PORT                  = "9394";
          SELF_HOSTED                               = "true";
          STORE_GEODATA                             = "true";
        };

        dependsOn = [ "dawarich_db" "dawarich_redis" "dawarich_app" ];

        extraOptions = [
          # healthcheck: simple process check
          "--health-cmd=pgrep -f sidekiq || exit 1"
          "--health-interval=10s"
          "--health-retries=30"
          "--health-start-period=30s"
          "--health-timeout=10s"
        ];
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 3000 ];
    allowedUDPPorts = [];
  };
}


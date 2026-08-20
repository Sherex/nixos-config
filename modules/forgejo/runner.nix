# Src: https://github.com/felschr/nixos-config/blob/10e76a521b232dafa1c398120c046c1e0abdafb2/services/forgejo/runner.nix#L9
{
  config,
  pkgs,
  lib,
  ...
}:

let
  name = "forgejo";
  cfg = config.${name};
  forgejoCfg = config.services.forgejo;
in
{
  options.${name}.localRunner.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.localRunner.enable {
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.local = {
        enable = true;
        url = config.services.forgejo.settings.server.ROOT_URL;
        tokenFile = ""; # dynamically retrieved from Forgejo (see further below)
        name = config.networking.hostName;
        labels = [
          "node-latest:docker://node:26-trixie"
          "node-26-trixie:docker://node:26-trixie"
          # Shims for GH workflows
          "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
          "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
          "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
          # Custom
          "nixos-full:docker://git.i-h.no/sherex/nixos-ci-image@sha256:c261431e2185825a6f4e87d43271ddaa1c22ccf6cf870adfe64d3f27e5464636"
          # Native (Shudders...)
          # "native:host"
        ];
        hostPackages = with pkgs; [
          # default
          bash
          coreutils
          curl
          gawk
          gitMinimal
          gnused
          nodejs
          wget

          nix
        ];
        settings = {
          container.network = "host";
          runner.capacity = 4;
        };
      };
    };

    nix.settings.allowed-users = [ "gitea-runner" ];
    nix.settings.trusted-users = [ "gitea-runner" ];

    # automatically get registration token from forgejo
    systemd.services.forgejo.postStart = lib.mkBefore ''
      ${pkgs.bash}/bin/bash -c '(while ! ${pkgs.netcat-openbsd}/bin/nc -z -U ${forgejoCfg.settings.server.HTTP_ADDR}; do echo "Waiting for unix ${forgejoCfg.settings.server.HTTP_ADDR} to open..."; sleep 2; done); sleep 2'
      actions="${lib.getExe config.services.forgejo.package} actions"
      echo -n TOKEN= > /run/forgejo/forgejo-runner-token
      $actions generate-runner-token >> /run/forgejo/forgejo-runner-token
    '';

    systemd.services.gitea-runner-local.serviceConfig = {
      EnvironmentFile = [ "/run/forgejo/forgejo-runner-token" ];
    };

    systemd.services.gitea-runner-local.wants = [ "forgejo.service" ];
    systemd.services.gitea-runner-local.after = [ "forgejo.service" ];

    environment.persistence."/persistent/safe" = {
      directories = [
        # Expects service to use DynamicUser
        {
          directory = "/var/lib/private/${config.systemd.services.gitea-runner-local.serviceConfig.StateDirectory}";
          user = "nobody";
          group = "nogroup";
          mode = "u=rwx,g=,o=";
        }
      ];
    };
    assertions = [
      {
        assertion = !!config.systemd.services.gitea-runner-local.serviceConfig.DynamicUser;
        message = "Current persistance directory configuration for Gitea Actions Runner expects gitea-runner-local DynamicUser service setting to be enabled";
      }
    ];
  };
}

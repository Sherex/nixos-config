{ config, pkgs, ... }:

let
  service = {
    name = "karlsentertainment";
    directory = "/srv/services/karlsentertainment";
    port = 8000;
    domain = "karlsentertainment.no";
    group = "${service.name}-mgm";
  };
in {
  environment.persistence."/persistent/safe".directories = [
    service.directory
  ];

  virtualisation.oci-containers.containers.karlsentertainment = {
    image = "ghcr.io/havsalt/karl-s-entertainment-productions:latest";
    ports = [
      "${toString service.port}:8000"
    ];
    volumes = [
      "${service.directory}/static:/app/static"
      "${service.directory}/data:/app/data"
    ];
    environment = {
      FORWARDED_ALLOW_IPS = "*"; # NOTE: Must match the internal podman container ip which changes often.
    };
    extraOptions = [
      "--health-cmd=curl -f http://localhost:8000"
      "--health-interval=30s"
      "--health-timeout=10s"
      "--health-retries=3"
      "--health-start-period=5s"
    ];
  };

  services.nginx = {
    virtualHosts."karlsentertainment.no" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass =
          "http://127.0.0.1:${toString service.port}";
        proxyWebsockets = true;
      };
      locations."/.hooks" = {
        proxyPass =
          "http://127.0.0.1:${toString config.services.webhook.port}";
        proxyWebsockets = true;
      };
    };
  };

  #users.users.webhook.home = "/srv/webhook";
  services.webhook = {
    enable = true;
    port = 8001;
    urlPrefix = ".hooks";
    openFirewall = false;

    environment = {
      #GIT_SSH_COMMAND = "${pkgs.openssh}/bin/ssh -i /srv/id_webhook -o StrictHostKeyChecking=no";
      GIT_TERMINAL_PROMPT = "0";
      GIT_ASKPASS = toString (pkgs.writeShellScript "webhook-git-askpass" ''
        echo $HOOK_GITHUB_TOKEN
      '');
    };

    hooks = {
      deploy = {
        command-working-directory = service.directory;
        response-message = "Karl website deployment triggered.";
        include-command-output-in-response = true;

        pass-environment-to-command = [
          {
            envname = "HOOK_GITHUB_TOKEN";
            source = "header";
            name = "X-GITHUB-TOKEN";
          }
        ];

        trigger-rule = {
          or = [
            {
              match = {
                type = "value";
                # WARN: Dynamically get the secret value. For available functions,
                #       see: https://github.com/adnanh/webhook/blob/master/internal/hook/hook.go#L760
                value = "Bearer <secret>";
                parameter = {
                  source = "header";
                  name = "Authorization";
                };
              };
            }
            {
              match = {
                type = "payload-hmac-sha1";
                # WARN: Dynamically get the secret value. For available functions,
                #       see: https://github.com/adnanh/webhook/blob/master/internal/hook/hook.go#L760
                secret = "<secret>";
                parameter = {
                  source = "header";
                  name = "X-Hub-Signature";
                };
              };
            }
          ];
        };
        execute-command = toString (pkgs.writeShellScript "deploy-karlsentertainment" ''
          PATH="$PATH:${pkgs.podman}/bin"

          set -euo pipefail

          echo "Deploying latest container image..."
          if ! sudo ${pkgs.systemd}/bin/systemctl restart podman-${service.name}; then
            echo "Deployment failed"
            exit 1
          fi

          echo "Deployment complete"
          echo "ENV_URL: https://${service.domain}"
        '');
      };
    };
  };
  security.sudo.extraRules = [{
    commands = let
      allowPodman = cmd: {
        command = "${pkgs.systemd}/bin/systemctl ${cmd} podman-${service.name}";
        options = [ "NOPASSWD" ];
      };
    in [
      allowPodman "start"
      allowPodman "restart"
      allowPodman "stop"
    ];
    groups = [ service.group ];
  }];
  users.groups.${service.group} = {};
  users.users.${config.services.webhook.user}.extraGroups = [service.group];
}

{ config, pkgs, ... }:

{
  environment.persistence."/persistent/safe".directories = [
    "/srv/karl-website"
  ];

  services.nginx = {
    virtualHosts."karlsentertainment.no" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass =
          "http://localhost:8000";
        proxyWebsockets = true;
      };
      locations."/.hooks" = {
        proxyPass =
          "http://localhost:8001";
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
    user = "sherex"; # WARN: Use separate user with only the necessary permissions.
    group = "users"; #       Same with group.

    environment = {
      #GIT_SSH_COMMAND = "${pkgs.openssh}/bin/ssh -i /srv/id_webhook -o StrictHostKeyChecking=no";
      GIT_TERMINAL_PROMPT = "0";
      GIT_ASKPASS = toString (pkgs.writeShellScript "webhook-git-askpass" ''
        echo $HOOK_GITHUB_TOKEN
      '');
    };

    hooks = {
      deploy = {
        command-working-directory = "/srv/karl-website";
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
        execute-command = toString (pkgs.writeShellScript "deploy-karl-website" ''
          PATH="$PATH:${pkgs.git}/bin:${pkgs.podman}/bin:${pkgs.podman-compose}/bin:${pkgs.openssh}/bin"

          set -euo pipefail
          echo "Deploying latest main"

          cd /srv/karl-website

          git config --add safe.directory /srv/karl-website

          # TODO: Make idempotent
          #git remote set-url origin https://x-access-token:$HOOK_GITHUB_TOKEN@github.com/Havsalt/Karl-s-Entertainment-Productions

          # Clean update from main
          git fetch origin main
          if ! git diff --quiet; then
            echo "Stashing local changes"
            git stash push
          fi

          git reset --hard origin/main

          # Reapply stash if it exists
          if git stash list | grep -q .; then
            echo "Reapplying stashed changes"
            git stash pop || {
              echo "Stash pop failed due to merge conflicts"
              exit 1
            }
          fi

          echo "Building and deploying"
          if ! podman compose up -d --build --force-recreate; then
            echo "Deployment failed"
            exit 1
          fi

          echo "Deployment complete"
          echo "ENV_URL: https://karlsentertainment.no"
        '');
      };
    };
  };

}

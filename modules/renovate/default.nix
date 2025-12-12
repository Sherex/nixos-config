{ config, pkgs, lib, home-manager, ... }:

let
  renovate-state = config.systemd.services.renovate.serviceConfig.StateDirectory;
  # Wrapper that uses a private store inside the service's StateDirectory
  nix-local-wrapper = pkgs.writeShellScriptBin "nix" ''
    export STATE_DIRECTORY="/var/lib/private/${renovate-state}" # Systemd's designated state dir
    export NIX_REMOTE = ""; # Use local state directory
    export NIX_STORE_DIR="$STATE_DIRECTORY/nix/store"
    export NIX_STATE_DIR="$STATE_DIRECTORY/nix/state"
    export NIX_LOG_DIR="$STATE_DIRECTORY/nix/log"
    export NIX_CONF_DIR="$STATE_DIRECTORY/nix/conf"

    mkdir -p "$NIX_STORE_DIR" "$NIX_STATE_DIR" "$NIX_LOG_DIR" "$NIX_CONF_DIR"

    # Initialize store if needed
    if [ ! -f "$NIX_STATE_DIR/db" ]; then
      ${pkgs.nix}/bin/nix-store --store "$NIX_STORE_DIR" --init
    fi

    exec ${pkgs.nix}/bin/nix \
      --store "$NIX_STORE_DIR" \
      --option fallback true \
      "$@"
  '';
in
{
  services.renovate = {
    enable = true;
    schedule = "*:0/30";
    runtimePackages = with pkgs; [
      nix-local-wrapper
      go
    ];

    environment = {
      LOG_LEVEL = "info";
    };

    credentials = {
      RENOVATE_TOKEN = config.sops.secrets."services/renovate/github-pat".path;
    };

    settings = {
      platform = "github";
      gitAuthor = "Renovate Bot IH <renovate@i-h.no>";
      autodiscover = true;
      autodiscoverFilter = ["Sherex/*" "sherex/*"];
      requireConfig = true; # ONLY run on repos with renovate.json
      onboarding = false;   # do NOT create onboarding PRs
    };
  };

  systemd.services.renovate.serviceConfig = {
    StateDirectory = "renovate"; # Already default in services.renovate. But set here to fail on eval if ever changed upstream as it is required by the script above
  };

  sops.secrets."services/renovate/github-pat" = {};
}


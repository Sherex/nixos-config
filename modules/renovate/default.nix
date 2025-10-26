{ config, pkgs, lib, home-manager, ... }:
{
  services.renovate = {
    enable = true;
    schedule = "*:0/15";
    runtimePackages = with pkgs; [
      nix
    ];

    credentials = {
      RENOVATE_TOKEN = "/srv/renovate/github-pat.token";
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
}


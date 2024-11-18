{ inputs, config, pkgs, lib,  ... }:

{
  # src: https://github.com/Misterio77/nix-config/blob/53c2671c6d174cccb3d987d2989d4fa85f97e5e3/hosts/common/global/tailscale.nix

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = ["--login-server ${config.services.headscale.settings.server_url}" "--advertise-exit-node"];
    openFirewall = true;
  };

  environment.persistence."/persistent/safe" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}


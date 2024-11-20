{ config, pkgs, lib, home-manager, ... }:

{
  users.groups.ssh-password-auth = {};

  services.openssh = {
    enable = true;
    hostKeys = [
      { type = "ed25519"; path = "/persistent/safe/etc/ssh/ssh_host_ed25519_key"; }
      { type = "rsa"; bits = 4096; path = "/persistent/safe/etc/ssh/ssh_host_rsa_key"; }
    ];

    settings = {
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      GatewayPorts = "clientspecified";
    };

    extraConfig = ''
      Match Group ${config.users.groups.ssh-password-auth.name}
      PasswordAuthentication yes
      Match all
      PasswordAuthentication no
    '';
  };

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    ignoreIP = [
      "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"
    ];
    bantime = "24h"; # Ban IPs for one day on the first ban
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate the bantime based on all the violations
    };
  };
}


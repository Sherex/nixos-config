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
}


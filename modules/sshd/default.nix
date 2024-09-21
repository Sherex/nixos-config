{ config, pkgs, lib, home-manager, ... }:

{
  services.openssh = {
    enable = true;
    hostKeys = [
      { type = "ed25519"; path = "/persistent/safe/etc/ssh/ssh_host_ed25519_key"; }
      { type = "rsa"; bits = 4096; path = "/persistent/safe/etc/ssh/ssh_host_rsa_key"; }
    ];

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}


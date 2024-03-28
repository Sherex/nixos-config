{ config, pkgs, lib, home-manager, ... }:

{
  services.openssh = {
    enable = true;
  };

  environment.persistence."/persistent/safe" = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}


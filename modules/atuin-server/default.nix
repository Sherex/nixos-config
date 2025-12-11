{ config, pkgs, lib, ... }:

let 
  name = "atuin";
  username = "${name}";
  data_path = "/srv/services/${name}";
  port = 8888;
  user = config.users.users.${username};
in
{
  services.atuin = {
    enable = true;
    host = "127.0.0.1";
    port = port;
    database = {
      uri = "sqlite://${data_path}/atuin.db";
    };
  };

  users = {
    groups.${username} = { };
    users.${username} = {
      isSystemUser = true;
      group = username;
    };
  };

  systemd.services.${name} = {
    after = [ "systemd-tmpfiles-resetup.service" ];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = user.name;
      Group = user.group;
      ReadWritePaths = [ data_path ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${data_path} 0750 ${user.name} ${user.group} -"
  ];

  environment.persistence."/persistent/safe".directories = [
    { directory = data_path; user = user.name; group = user.group; mode = "u=rwx,g=,o="; }
  ];

  services.nginx.virtualHosts."${name}.i-h.no" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null; # Use DNS challenge
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''
        allow 127.0.0.1;
        allow 100.70.0.0/16; # Tailscale
        deny all;
      '';
    };
  };
}


{ inputs, config, pkgs, lib,  ... }:

let 
  name = "calibre-web";
  subdomain = "calibre";
  username = "${name}";
  data_path = "/srv/services/${name}";
  port = 30001;
  user = config.users.users.${username};
in {
  services.calibre-web = {
    enable = true;
    listen.ip = "127.0.0.1";
    listen.port = 30001;
    dataDir = data_path;
    openFirewall = false;
    options = {
      calibreLibrary = "${data_path}/library";
      enableKepubify = true;
      enableBookConversion = true;
      enableBookUploading = true;
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
    "d ${data_path}/library 0750 ${user.name} ${user.group} -"
  ];

  environment.persistence."/persistent/safe".directories = [
    { directory = data_path; user = user.name; group = user.group; mode = "u=rwx,g=,o="; }
  ];

  services.nginx.virtualHosts."${subdomain}.i-h.no" = {
    useACMEHost = "i-h.no";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''
        allow 127.0.0.1;
        allow 100.70.0.0/16; # Tailscale
        deny all;

        client_max_body_size 0;
      '';
    };
    locations."^~ /opds" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''
        allow all;
      '';
    };
  };
}


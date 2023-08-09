{ config, pkgs, lib, ... }:

let
  borgId = "vf5v43p8";
  borgDomain = "${borgId}.repo.borgbase.com";
  borgRepo = "ssh://${borgId}@${borgDomain}/./repo";
  setOwner = username:
    let
      user = config.users.users.${username};
    in {
      owner = user.name;
      group = user.group;
    };
in
{
  users.groups.borg = {};
  users.users.borg = {
    isSystemUser = true;
    group = config.users.groups.borg.name;
    createHome = true;
    home = "/home-system/borg";
  };

  sops.secrets = {
    "user/borg/passphrase" = setOwner "borg";
    "user/borg/private-key" = setOwner "borg";
  };

  programs.ssh.knownHosts.${borgDomain} = {
    publicKey = "ssh-ed25519 SHA256:yufQ7QKrcSOCj43GdTD8vfNmJwJH6RcTgpLQQKjXc5Y";
  };

  services.borgbackup.jobs.safe = {
    user = config.users.users.borg.name;
    group = config.users.users.borg.group;
    paths = "/persistent/safe";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${toString config.sops.secrets."user/borg/passphrase".path}";
    };
    environment.BORG_RSH = "ssh -i ${toString config.sops.secrets."user/borg/private-key".path}";
    repo = borgRepo;
    compression = "auto,zstd";
    startAt = "hourly";
  };
}



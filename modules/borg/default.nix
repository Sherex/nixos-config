{ config, pkgs, lib, ... }:

let
  borgId = "vf5v43p8";
  borgDomain = "${borgId}.repo.borgbase.com";
  borgRepo = "ssh://${borgId}@${borgDomain}/./repo";
  borgPublicKey = "ssh-ed25519 SHA256:yufQ7QKrcSOCj43GdTD8vfNmJwJH6RcTgpLQQKjXc5Y";
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
    home = "/home/borg";
  };

  # Set an ACL on directory to allow borg to read everything below
  systemd.tmpfiles.rules = [
    "A /persistent/safe - - - - user:${config.users.users.borg.name}:r-X"
  ];

  sops.secrets = {
    "user/borg/passphrase" = setOwner config.users.users.borg.name;
    "user/borg/private-key" = setOwner config.users.users.borg.name;
  };

  programs.ssh.knownHosts.${borgDomain} = {
    publicKey = borgPublicKey;
  };

  services.borgbackup.jobs.safe = {
    user = config.users.users.borg.name;
    group = config.users.users.borg.group;
    paths = "/persistent/safe";
    patterns = [
      "- .cache"
      "- .npm"
      "- .local/state/lesshst" # Permission issues with ACLs
    ];
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${toString config.sops.secrets."user/borg/passphrase".path}";
    };

    # BUG: Possible bug where ssh look in the user's own knownhosts file and not in the system one defined above.
    #      Which means ssh won't allow the connection in a non-interactive mode.
    #      Could potentially be resolved by symlinking the system knownhosts file. Any issues doing that?
    environment.BORG_RSH = "ssh -i ${toString config.sops.secrets."user/borg/private-key".path}";
    repo = borgRepo;
    compression = "auto,zstd";
    startAt = "hourly";
  };
}



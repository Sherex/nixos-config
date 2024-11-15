{ config, pkgs, lib, ... }:

let
  borgId = "vf5v43p8";
  borgDomain = "${borgId}.repo.borgbase.com";
  borgRepo = "ssh://${borgId}@${borgDomain}/./repo";
  borgPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMS3185JdDy7ffnr0nLWqVy8FaAQeVh1QYUSiNpW5ESq";
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

  sops.secrets = {
    "user/borg/passphrase" = setOwner config.users.users.borg.name;
    "user/borg/private-key" = setOwner config.users.users.borg.name;
  };

  programs.ssh.knownHosts.${borgDomain} = {
    publicKey = borgPublicKey;
  };

  systemd.services."borgbackup-job-safe".serviceConfig.AmbientCapabilities = "CAP_DAC_READ_SEARCH";
  services.borgbackup.jobs.safe = {
    user = config.users.users.borg.name;
    group = config.users.users.borg.group;
    paths = "/persistent/safe";
    exclude = [
      ".cache"
      ".npm"
      "/persistent/safe/home/borg/.config/borg/security/*/nonce"
    ];
    extraCreateArgs = [
      "--exclude-if-present"
      ".no-backup"
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
    prune.keep = {
      within = "3d";
      daily = 7;
      weekly = 4;
      monthly = -1;
    };
  };
}



{ config, pkgs, lib, home-manager, impermanence, ... }:

let
  locations = rec {
    driveDevicePath = config.fileSystems."/".device;
    rootMountPoint = /mnt;
    hibernationFlagFilePath = "/swap/hibernation-flag";
  };
  paths = builtins.mapAttrs (key: loc: toString loc) locations;
in
{
  imports = [
    impermanence.nixosModule
  ];

  fileSystems."/".neededForBoot = true;
  fileSystems."/persistent/safe".neededForBoot = true;
  fileSystems."/persistent/unsafe".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;

  environment.persistence."/persistent/safe" = {
    hideMounts = true;
    directories = [
      "/home"
      "/var/lib/bluetooth"
    ];
    files = [
      "/etc/adjtime"
      "/etc/machine-id"
      "/etc/wpa_supplicant.conf"
    ];

    # TODO: Move to user config?
    #users.sherex = {
    #  directories = [
    #    "documents"
    #    "downloads"
    #    "nixconf" # TODO: Temporary while still figuring shit out
    #    ".config/qutebrowser" # Bookmarks and autoconfig
    #  ]
    #}
  };

  environment.persistence."/persistent/unsafe" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/upower"
      "/var/lib/tlp"
    ];
    files = [
    ];
  };

  security.sudo.extraConfig = ''
    # Don't prompt the sudo lecture after each reboot
    Defaults lecture = never
  '';

  #home-manager.users.sherex = { pkgs, ... }: {
    # TODO: Use home-manager for user file persistance?
  #};

  # Source (but quite modified):
  # https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html#darling-erasure
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    DRIVE_PATH="${paths.driveDevicePath}"
    MNT_PATH="${paths.rootMountPoint}"
    BIN_PATH="${pkgs.coreutils.outPath + "/bin"}"
    PATH="$PATH:$BIN_PATH"
    SUBVOL_DIR_PATH="$MNT_PATH/subvolumes"
    HIBERNATION_FILE_PATH="$SUBVOL_DIR_PATH${paths.hibernationFlagFilePath}"
    SNAPSHOT_DIR_PATH="$SUBVOL_DIR_PATH/snapshots"
    ROOT_SUBVOL="$SUBVOL_DIR_PATH/tmp"
    ROOT_BLANK_SUBVOL="$ROOT_SUBVOL-blank"
    ROOT_SNAPSHOT="$SNAPSHOT_DIR_PATH/tmp@`date -Iseconds | cut -f1 -d"+" -`"

    # Create mountpoint
    echo "Creating directory $MNT_PATH"
    mkdir -p $MNT_PATH

    # We first mount the btrfs root to $SUBVOL_DIR_PATH
    # so we can manipulate btrfs subvolumes.
    echo "Mounting BTRFS root"
    mount -o subvol=/ $DRIVE_PATH $MNT_PATH

    if [ ! -f "$HIBERNATION_FILE_PATH" ]; then

      # Ensure directories exist
      echo "Ensure $SUBVOL_DIR_PATH $SNAPSHOT_DIR_PATH exists"
      mkdir -p "$SUBVOL_DIR_PATH" "$SNAPSHOT_DIR_PATH"

      # Snapshot the existing root subvolume
      btrfs subvolume snapshot -r "$ROOT_SUBVOL" "$ROOT_SNAPSHOT"

      # Delete all subvolumes inside the root subvolume
      echo "Searching for subvolumes inside $ROOT_SUBVOL"
      # Why in the world doesn't it return the absolute path??
      # And why is not relative to cwd either??!
      btrfs subvolume list -o $ROOT_SUBVOL |
      cut -f9 -d' ' |
      while read subvolume; do
        echo "Deleting $subvolume subvolume..."
        btrfs subvolume delete "$MNT_PATH/$subvolume"
      done &&
      echo "Deleting $ROOT_SUBVOL subvolume..." &&
      btrfs subvolume delete $ROOT_SUBVOL

      echo "Restoring blank $ROOT_SUBVOL subvolume..."
      btrfs subvolume snapshot $ROOT_BLANK_SUBVOL $ROOT_SUBVOL

    else
      echo "System is resuming from hibernation, skipping root refresh..."
    fi

    echo "Unmounting BTRFS root"
    umount $MNT_PATH
  '';

  systemd.services.set-hibernation-flag = {
    enable = true;
    description = "Places a file in /swap to indicate that the system will hibernate";
    before = [ "systemd-hibernate.service" ];
    path = [ "/run/current-system/sw" ];
    script = ''
      touch ${paths.hibernationFlagFilePath}
    '';
    requiredBy = [ "hibernate.target" ];
  };

  systemd.services.remove-hibernation-flag = {
    enable = true;
    description = "Removes a file in /swap placed there by the service set-hibernation-flag.service";
    after = [ "systemd-hibernate.service" ];
    path = [ "/run/current-system/sw" ];
    script = ''
      rm -f ${paths.hibernationFlagFilePath}
    '';
    wantedBy = [ "hibernate.target" ];
  };
}


{ config, pkgs, lib, ... }:

let
  locations = rec {
    driveDevicePath = /dev/disk/by-label/nixos;
    rootMountPoint = /mnt;
    swapSubvolLocation = /subvolumes/swap;
    swapFileLocation = swapSubvolLocation + /swapfile;
    swapSubvolMountPoint = /swap;
    swapFileSize = "16g";
  };
  paths = builtins.mapAttrs (key: loc: toString loc) locations;
in
{
  boot.initrd.postDeviceCommands = pkgs.lib.mkAfter ''
    # Create mountpoint
    echo "Creating directory ${paths.rootMountPoint}"
    mkdir -p "${paths.rootMountPoint}"

    echo "Mounting BTRFS root"
    mount -o subvol=/ "${paths.driveDevicePath}" "${paths.rootMountPoint}"

    [[ -f ${paths.swapFileLocation} ]] \
    && echo "Swap file exists; early return" \
    && exit 0

    # Ensure subvol parent directory exists
    echo "Ensure ${dirOf (paths.rootMountPoint + paths.swapSubvolLocation)} exists"
    mkdir -p "${dirOf (paths.rootMountPoint + paths.swapSubvolLocation)}"

    # Create swap subvolume
    btrfs subvolume create "${paths.rootMountPoint + paths.swapSubvolLocation}"

    # Ensure swapfile parent directory exists
    # (in case the swapfile lives in a subdirectory in the subvolume)
    echo "Ensure ${dirOf (paths.rootMountPoint + paths.swapFileLocation)} exists"
    mkdir -p "${dirOf (paths.rootMountPoint + paths.swapFileLocation)}"

    # Create a BTRFS compatible swapfile
    echo "Create swapfile at ${paths.rootMountPoint + paths.swapFileLocation}"
    btrfs filesystem mkswapfile --size "${paths.swapFileSize}" ${paths.rootMountPoint + paths.swapFileLocation}

    # Unmount BTRFS root
    umount ${paths.rootMountPoint}
  '';

  fileSystems."${paths.swapSubvolMountPoint}" = {
    device = "${paths.driveDevicePath}";
    fsType = "btrfs";
    options = [ "subvol=${dirOf paths.swapFileLocation}" ];
  };

  swapDevices = [{
    device = "${paths.swapSubvolMountPoint}/${baseNameOf paths.swapFileLocation}";
  }];

  # Hibernation
  boot.resumeDevice = paths.driveDevicePath;
  # TODO: This needs to be specified in a more dynamic way
  # Update with "sudo btrfs inspect-internal map-swapfile -r /swap/swapfile"
  boot.kernelParams = [ "resume_offset=4768391" ]; 
}

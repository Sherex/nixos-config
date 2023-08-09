SYSTEM_NAME="$1"

NIXOS_CONFIG_GIT_REPO="https://github.com/Sherex/nixos-config"

BTRFS_DRIVE=/dev/disk/by-label/nixos
BOOT_DRIVE=/dev/disk/by-label/boot

BTRFS_MOUNT=/mnt-btrfs
SUBVOL_DIR="$BTRFS_MOUNT/subvolumes"

if [[ -z "$1" ]]; then
  echo "Error: Please specify a system name which has a configuration option in flake.nix"
  exit 1
fi

if [[ ! -a "$BTRFS_DRIVE" ]]; then
  echo "Error: Invalid BTRFS drive label, expected `basename $BTRFS_DRIVE`"
  exit 1
fi

if [[ ! -a "$BOOT_DRIVE" ]]; then
  echo "Error: Invalid BOOT drive label, expected `basename $BOOT_DRIVE`"
  exit 1
fi

## Initial BTRFS setup
mkdir -p "$BTRFS_MOUNT"
mount "$BTRFS_DRIVE" "$BTRFS_MOUNT"

mkdir -p "$SUBVOL_DIR"
btrfs subvolume create "$SUBVOL_DIR/safe"
btrfs subvolume create "$SUBVOL_DIR/unsafe"
btrfs subvolume create "$SUBVOL_DIR/tmp"
btrfs subvolume snapshot -r "$SUBVOL_DIR/tmp" "$SUBVOL_DIR/tmp-blank"

mkdir -p "$SUBVOL_DIR/tmp/persistent/safe"
mkdir -p "$SUBVOL_DIR/tmp/persistent/unsafe/nix"

git clone $NIXOS_CONFIG_GIT_REPO  "$SUBVOL_DIR/unsafe/nixos-config"

## NixOS Install
mkdir -p /mnt
mount $BTRFS_DRIVE /mnt -o subvol=subvolumes/tmp
mount $BTRFS_DRIVE /mnt/persistent/safe -o subvol=subvolumes/safe
mount $BTRFS_DRIVE /mnt/persistent/unsafe -o subvol=subvolumes/unsafe

mkdir -p /mnt/persistent/unsafe/nix
mkdir -p /mnt/nix
mount /mnt/persistent/unsafe/nix /mnt/nix -o bind
mkdir -p /mnt/etc/nixos
mount /mnt/persistent/unsafe/nixos-config /mnt/etc/nixos -o bind
mkdir -p /mnt/boot
mount $BOOT_DRIVE /mnt/boot

## User setup
echo "Please enter passowrd for user Sherex:"
mkpasswd > /mnt/persistent/safe/sherex-password-hash

nixos-install --flake "/mnt/etc/nixos#$1" --impure

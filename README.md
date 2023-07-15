# NixOS Configuration
This repo contains my configuration for my laptop running NixOS.  
I'm in the middle of convert my Arch configuration over to Nix, so there will most likely be inconsistencies until I migrate my dotfiles and add them to this repo.

## Initial setup
### Boot LiveCD
1. Setup filesystem
  - vfat - boot - 512M - /boot
  - btrfs - nixos - max -
    - /subvolumes/tmp - / # Root is cleaned each boot
    - /subvolumes/tmp-blank - N/M # Snapshot which tmp is rolled back to each boot
    - /subvolumes/safe - /persistent/safe # Is persisted and backed up
    - /subvolumes/unsafe - /persistent/unsafe # Is persisted, but NOT backed up
      - bind-mount - /persistent/unsafe/nix - /nix
2. Use `mkpasswd -m sha512crypt > /mnt/subvolumes/safe/sherex-password-hash` to create a new password. (Provided the `nixos` disk is mounted at `/mnt`)
3. Build current config and output it at the new filesystem
4. Reboot into the new filesystem with current configuration

## Updating channels
1. `sudo nixos-rebuild switch --flake . --recreate-lock-file`
2. Then commit flake.lock

## Rebuilding flow
1. Edit the relevant `*.nix` file.
2. `nix-rebuild switch --flake .`

# License
[MIT](LICENSE)

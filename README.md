<p align="center">
  <img src="https://raw.githubusercontent.com/sherex/nixos-config/main/assets/nixos-white.svg" width="500px" alt="NixOS logo"/>
</p>
<h1 align="center">Configuration</h1>

This repo contains my configuration for my laptop running NixOS.  
I'm in the middle of converting my Arch configuration over to Nix, so there will most likely be inconsistencies until I migrate my dotfiles and add them to this repo.

## Initial setup
### Boot LiveCD
1. Setup filesystems

#### Disk partitioning
|Filesystem|Label|Size|Mountpoint|
|-|-|-|-|
| vfat | boot | 512M | `/boot` |
| btrfs | nixos | 2G+ | `/mnt` |

#### Subvolume mounts
|Subvolume|Mountpoint|Comment|
|-|-|-|
| `/subvolumes/tmp` | `/` | Root is rolled back to a blank snapshot each boot |
| `/subvolumes/tmp-blank` | Not mounted | Snapshot which tmp is rolled back to each boot |
| `/subvolumes/safe` | `/persistent/safe` | Is persisted and backed up |
| `/subvolumes/unsafe` | `/persistent/unsafe` | Is persisted, but **NOT** backed up |

#### Bind mounts
|Source|Mountpoint|Comment|
|-|-|-|
| `/persistent/unsafe/nix` | `/nix` | Bind mount for Nix store |

2. Put the secrets file at `/persistent/safe/secrets/default.yaml` and the age keyfile at `/persistent/safe/keys/nixtop.txt`
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

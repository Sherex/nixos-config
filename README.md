# NixOS Configuration
This repo contains my configuration for my laptop running NixOS.  
I'm in the middle of convert my Arch configuration over to Nix, so there will most likely be inconsistencies until I migrate my dotfiles and add them to this repo.

## Initial setup
### Boot LiveCD
1. Setup filesystem
2. Build current config and output it at the new filesystem
3. Reboot into the new filesystem with current configuration

### Boot current config
1. Add and update channels  
```sh
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
sudo nix-channel --update
```

## Rebuilding flow
1. Edit the relevant `*.nix` file.
2. `nix-rebuild switch`

# License
[MIT](LICENSE)

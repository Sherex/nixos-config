{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/gpu
    ../modules/swap
    ../modules/hyprland
    ../modules/sound
    ../modules/impermanence
    ../modules/sops
    ../modules/borg
    ../modules/sshd
    ../modules/vpn
    ../modules/tailscale
    ../modules/kde-connect
  ];

  boot.loader.efi = {
    canTouchEfiVariables = lib.mkDefault true;
    # This is handled by Disko, but not all systems are converted yet
    efiSysMountPoint = lib.mkDefault config.fileSystems."/boot".mountPoint;
  };
  boot.loader.timeout = 1;
  boot.loader.grub = {
    enable = true;
    efiSupport = lib.mkDefault true;
    devices = [ "nodev" ];
    default = lib.mkDefault "0";
    memtest86.enable = true;
  };

  time.timeZone = "Europe/Oslo";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "no-latin1";
  };

  users.groups = {
    nix-trusted = {};
    nix-allowed = {};
  };

  users.groups.wheel-nopass = {};
  security.sudo = {
    extraRules = [
      # Create a sudo group meant for temporary access to sudo without password requiring user password
      { groups = [ config.users.groups.wheel-nopass.name ]; commands = [
        { command = "ALL"; options = [ "SETENV" "NOPASSWD" ]; }
      ]; }
    ];
  };

  # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    use-xdg-base-directories = true;
    trusted-users = [ "@nix-trusted" ];
    allowed-users = [ "@nix-allowed" ];
    download-buffer-size = 1048576000;
    auto-optimise-store = true;
    builders-use-substitutes = true;
    trusted-public-keys = [ "nix-cache-s3:bqvZzMPh1+gbFBWcnvXk7FtyCck1Phet8lV1iA4/uvU=" ];
    extra-substituters = [ "https://nix-cache.web.i-h.no" ];
  };
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    neovim
    wget
    powertop
    fakeroot
    killall
    efibootmgr
    dool
    dnsutils
    lsof
    ncdu
    jq
    screen
    traceroute
    tree
    pciutils
  ];

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}


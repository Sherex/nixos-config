{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/swap
    ../users/sherex-server.nix
    ../modules/impermanence
    #../modules/sops
    #../modules/borg
    ../modules/sshd
    ../modules/tailscale
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
    default = "0";
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

  # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    use-xdg-base-directories = true;
    trusted-users = [ "@nix-trusted" ];
    allowed-users = [ "@nix-allowed" ];
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



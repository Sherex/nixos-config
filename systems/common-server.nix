{ config, pkgs, ... }:

{
  imports = [
    ../modules/swap
    ../sherex-server.nix
    ../modules/impermanence
    #../modules/sops
    #../modules/borg
    ../modules/sshd
  ];

  #boot.loader.efi = {
  #  canTouchEfiVariables = true;
  #  efiSysMountPoint = config.fileSystems."/boot".mountPoint;
  #};
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = [ "nodev" ];
    default = "saved";
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

  # Enable sound.
  sound.enable = false;
  # hardware.pulseaudio.enable = true;

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}



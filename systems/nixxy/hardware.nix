{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Contabo firmware only support Legacy/BIOS
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.efiSupport = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixxy";
    fsType = "btrfs";
    options = [ "subvol=subvolumes/tmp" "compress=zstd:1" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/nixboot";
    fsType = "vfat";
  };

 fileSystems."/persistent/unsafe" = {
    device = "/dev/disk/by-label/nixxy";
    fsType = "btrfs";
    options = [ "subvol=subvolumes/unsafe" "compress=zstd:1" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/persistent/safe" = {
    device = "/dev/disk/by-label/nixxy";
    fsType = "btrfs";
    options = [ "subvol=subvolumes/safe" "compress=zstd:1" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/persistent/unsafe/nix";
    fsType = "none";
    options = [ "bind" ];
    neededForBoot = true;
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s20f0u3c2.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

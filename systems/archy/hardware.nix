{ config, lib, pkgs, modulesPath, ... }:

let
  arch = {
    boot-label = "arch";
    root-uuid = "97AB-1155";
  };
  winshit = {
    root-uuid = "AECC7078CC703CA1";
  };
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=subvolumes/tmp" "compress=zstd:1" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/nixboot";
    fsType = "vfat";
  };

  fileSystems."/persistent/unsafe" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=subvolumes/unsafe" "compress=zstd:1" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/persistent/safe" = {
    device = "/dev/disk/by-label/nixos";
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

  fileSystems."/media/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [ "compress=zstd:1" "noatime" ];
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

  # The Z370 Gaming PLUS has an idiotic way of handling UEFI boot and requires the bootloader to reside at the fallback location.
  # SRC:https://wiki.archlinux.org/title/GRUB/EFI_examples#B150_PC_MATE_/_B250_PC_MATE_/_H110I_PRO_/_Z370_GAMING_PLUS_/_MPG_B760I_EDGE_WIFI
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.grub.extraEntries = ''
    menuentry 'Arch Linux' {
      set gfxpayload=keep
      insmod gzio
      insmod part_gpt
      insmod fat
      insmod search_fs_uuid
      search --no-floppy --fs-uuid --set=root ${arch.root-uuid}
      echo    'Loading Linux linux ...'
      linux   /archyboi-boot/vmlinuz-linux root=LABEL=${arch.boot-label} rw rootflags=subvol=subvol/root  loglevel=3 quiet intel_iommu=on pcie_acs_override=downstream
      echo    'Loading initial ramdisk ...'
      initrd  /archyboi-boot/intel-ucode.img /archyboi-boot/initramfs-linux.img
     }

    menuentry "WinShit" {
      insmod part_gpt
      insmod fat
      insmod search_fs_uuid
      insmod chain
      search --fs-uuid --set=root ${winshit.root-uuid}
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';

  systemd.services.sound-blaster-unmute = {
    description = "Unmutes the Sound Blaster soundcard after startup";
    enable = false; # A little buggy on restart

    # These dependencies are just approximations of where in the boot process
    # this should start and are not hard requirements.
    wantedBy = [ "alsa-store.service" ];
    after = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };

    # Max 30 restart attempts within 1 hour
    startLimitBurst = 30;
    startLimitIntervalSec = 3600;

    path = [ pkgs.alsa-utils ];
    script = ''
      set -e

      # Fail if card is unmuted (it will eventually be muted by some ghost service starting after login)
      amixer --card 2 get Front | grep -E 'Front (Left|Right).+\[off\]'

      echo "--------"

      amixer --card 2 set Front unmute

      echo "--------"

      # Fail if card is still muted
      amixer --card 2 get Front | grep -E 'Front (Left|Right).+\[on\]'
    '';
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    drivers = [ "amd" ];
  };
}

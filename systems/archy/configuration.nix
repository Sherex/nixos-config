{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../common.nix
    ../../modules/gpu
    ../../modules/gaming
    ../../modules/virtualization
  ];

  networking.hostName = "Archy";

  networking.wireless.enable = false;

  boot = {
    initrd.kernelModules = lib.mkBefore [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
 #     "vfio_virqfd"
    ];

    kernelParams = [
      # enable IOMMU
      "intel_iommu=on"
      # isolate the GPU
      "vfio-pci.ids=05:00.0,05:00.1"
    ];
  };

  boot.initrd.availableKernelModules = [ "vfio-pci" ];
  boot.initrd.preDeviceCommands = ''
    DEVS="0000:05:00.0 0000:05:00.1"
    for DEV in $DEVS; do
      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
    modprobe -i vfio-pci
  '';

  hardware.opengl.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}


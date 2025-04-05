{ config, pkgs, lib, ... }:

{
  config = lib.mkIf (builtins.elem "nvidia" config.hardware.graphics.drivers) {
    environment.systemPackages = with pkgs; [
      nvtopPackages.nvidia
    ];

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia-container-toolkit.enable = true;

    hardware.nvidia = {
      # https://wiki.archlinux.org/title/Kernel_mode_setting

      # The current stable nvidia driver is utterly broken. Use
      # production for now to work around stuff like this:
      # https://forums.developer.nvidia.com/t/535-86-05-low-framerate-vulkan-apps-stutter-under-wayland-xwayland/26147
      # package = config.boot.kernelPackages.nvidiaPackages.production;
      modesetting.enable = true;
      # Power management is required to get nvidia GPUs to behave on
      # suspend, due to firmware bugs. Aren't nvidia great?
      powerManagement.enable = true;
      open = false;
    };

    boot.extraModprobeConfig =
      "options nvidia "
      + lib.concatStringsSep " " [
        # nvidia assume that by default your CPU does not support PAT,
        # but this is effectively never the case in 2023
        "NVreg_UsePageAttributeTable=1"
        # This may be a noop, but it's somewhat uncertain
        "NVreg_EnablePCIeGen3=1"
        # This is sometimes needed for ddc/ci support, see
        # https://www.ddcutil.com/nvidia/
        #
        # Current monitor does not support it, but this is useful for
        # the future
        "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
        # When (if!) I get another nvidia GPU, check for resizeable bar
        # settings
      ];

    environment.variables = {
      # Required to run the correct GBM backend for nvidia GPUs on wayland
      GBM_BACKEND = "nvidia-drm";
      # Apparently, without this nouveau may attempt to be used instead
      # (despite it being blacklisted)
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # Hardware cursors are currently broken on nvidia
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}



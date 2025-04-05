{ config, pkgs, lib, ... }:

{
  config = lib.mkIf (builtins.elem "amd" config.hardware.graphics.drivers) {
    services.xserver.videoDrivers = ["amdgpu"];

    hardware.amdgpu = {
      opencl.enable = true;
      amdvlk.enable = true;
    };

  };
}

{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
  ];

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.amdgpu = {
    opencl.enable = true;
    amdvlk.enable = true;
  };

}


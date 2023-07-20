{ config, pkgs, lib, home-manager, ... }:

{
  boot.kernelParams = [ "pcie_aspm=force" ];

  powerManagement.cpuFreqGovernor = "schedutil";

  services.tlp ={
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  services.upower.enable = true;

  services.thermald.enable = true;

  home-manager.users.sherex = { pkgs, ... }: {
    services.batsignal.enable = true;
  };
}



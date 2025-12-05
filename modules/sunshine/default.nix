{ config, pkgs, lib, ... }:
{
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    autoStart = true;
  };
}




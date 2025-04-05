{ config, pkgs, lib, ... }:

let
  cfg = config.hardware.graphics;
  hasAnyDriverDeclared = (lib.length cfg.drivers) != 0;
  gpuDriverModules = {
    amd = ./amd.nix;
    nvidia = ./nvidia.nix;
    intel = ./intel.nix;
  };
in {
  options.hardware.graphics.drivers = lib.mkOption {
    type = lib.types.listOf (lib.types.enum (builtins.attrNames gpuDriverModules));
    description = ''
      List of GPU drivers to enable. Possible values: ${builtins.concatStringsSep ", " (builtins.attrNames gpuDriverModules)}.
    '';
  };

  config = lib.mkIf hasAnyDriverDeclared {
    environment.systemPackages = with pkgs; [
      gpu-viewer
      clinfo
    ];
  };

  imports = builtins.attrValues gpuDriverModules;
}

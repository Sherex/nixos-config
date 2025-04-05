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
    default = [];
    description = ''
      List of GPU drivers to enable. Possible values: ${builtins.concatStringsSep ", " (builtins.attrNames gpuDriverModules)}.
    '';
  };

  config = lib.mkIf hasAnyDriverDeclared {
    nixpkgs.config.packageOverrides = pkgs: {
      # Build a custom version of nvtop with support just for my enabled GPUs
      nvtopPackages.custom = pkgs.nvtopPackages.amd.override (
        { amd = false; } //
        (builtins.listToAttrs (map (gpu: {
            name = gpu;
            value = true;
          }) cfg.drivers))
      );
    };
    environment.systemPackages = with pkgs; [
      gpu-viewer
      clinfo
      nvtopPackages.custom
    ];
  };

  imports = builtins.attrValues gpuDriverModules;
}

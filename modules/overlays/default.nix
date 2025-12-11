{ config, pkgs, lib, home-manager, ... }:

{
  ## Example overlay
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     hyprland = prev.hyprland.overrideAttrs {
  #       src = final.fetchFromGitHub {
  #         owner = "hyprwm";
  #         repo = "hyprland";
  #         fetchSubmodules = true;
  #         tag = "v0.52.0";
  #         hash = "sha256-5jYD01l95U/HTfZMAccAvhSnrWgHIRWEjLi9R4wPIVI=";
  #       };
  #     };
  #   })
  # ];
}



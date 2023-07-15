{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, home-manager, impermanence }@attrs: {

    nixosConfigurations.NixTop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configuration.nix
        # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
        # Source: https://ayats.org/blog/channels-to-flakes/
        { nix.registry.nixpkgs.flake = nixpkgs; }
      ];
    };
  };
}

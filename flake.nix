{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, sops-nix, disko }@attrs:
  let
    nixosSystem = nixpkgs: attrs: name:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./systems/${name}/configuration.nix
          disko.nixosModules.disko
          # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
          # Source: https://ayats.org/blog/channels-to-flakes/
          { nix.registry.nixpkgs.flake = nixpkgs; }
        ];
      };
  in {
    nixosConfigurations.NixTop = nixosSystem nixpkgs attrs "nixtop";

    nixosConfigurations.Archy = nixosSystem nixpkgs attrs "archy";

    nixosConfigurations.Nixxy = nixosSystem nixpkgs attrs "nixxy";

    nixosConfigurations.Nixxer = nixosSystem nixpkgs attrs "nixxer";

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}

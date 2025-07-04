{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

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

  outputs = { self, nixpkgs, home-manager, impermanence, sops-nix, disko, nixpkgs-stable }@attrs:

  let
    nixosSystem = nixpkgs: attrs: name:
      nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = attrs // {
            pkgs-stable = import nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };
          };
        modules = [
          ./systems/${name}/configuration.nix
          home-manager.nixosModules.home-manager
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

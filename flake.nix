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
  };

  outputs = { self, nixpkgs, home-manager, impermanence, sops-nix }@attrs: {
    nixosConfigurations.NixTop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./systems/nixtop/configuration.nix
        # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
        # Source: https://ayats.org/blog/channels-to-flakes/
        { nix.registry.nixpkgs.flake = nixpkgs; }
      ];
    };

    nixosConfigurations.Archy = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./systems/archy/configuration.nix
        # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
        # Source: https://ayats.org/blog/channels-to-flakes/
        { nix.registry.nixpkgs.flake = nixpkgs; }
      ];
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}

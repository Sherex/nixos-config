{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-borgbackup.url = "github:Scrumplex/nixpkgs/nixos/borgbackup/fix-extraArgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-librewolf.url = "github:nix-community/home-manager?ref=pull/5684/head";

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

  outputs = { self, nixpkgs, home-manager, impermanence, sops-nix, nixpkgs-borgbackup, home-manager-librewolf, disko }@attrs:
  let
    nixosSystem = nixpkgs: attrs: name:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          {
            disabledModules = [ "services/backup/borgbackup.nix" ];
            imports = [ (nixpkgs-borgbackup.outPath + "/nixos/modules/services/backup/borgbackup.nix") ];
          }
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

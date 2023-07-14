let
  channels = {
    nixos-config =  { ref = "/etc/nixos/configuration.nix"; };
    nixpkgs =       { ref = "bf57c599729771cd23054a18c0f3a391ae85e193"; repo = "NixOS/nixpkgs"; };
    nixos =         { ref = "f2406198ea0e4e37d4380d0e20336c575b8f8ef9"; repo = "NixOS/nixpkgs"; };
    home-manager =  { ref = "e42fb59768f0305085abde0dd27ab5e0cc15420c"; repo = "nix-community/home-manager"; };
  };
  createGitHubArchiveUrl = { repo, ref }: "https://github.com/${repo}/archive/${ref}.tar.gz";
in {
  repositories = builtins.mapAttrs (name: channel:
    if builtins.hasAttr "repo" channel
    then createGitHubArchiveUrl channel
    else channel.ref
  ) channels;
}

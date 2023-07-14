let
  channels = {
    nixos-config =  { ref = "/etc/nixos/configuration.nix"; };
    nixpkgs =       { ref = "df1eee2aa65052a18121ed4971081576b25d6b5c"; repo = "NixOS/nixpkgs"; };
    nixos =         { ref = "2de8efefb6ce7f5e4e75bdf57376a96555986841"; repo = "NixOS/nixpkgs"; };
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

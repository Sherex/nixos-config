{ config, pkgs, lib, home-manager, ... }:

let
  username = "sherex";
  user = config.users.users.${username};
  placeInHome = (path: {
    owner = user.name;
    path = "${user.home}/${toString path}";
  });
in
{
  # TODO: Figure out a way to execute this or otherwise create the .ssh diretory before sops creates it.'
  #       If Sops wins the race; home-manager does not have the permission to create the config file.
  #environment.postBuild = ''
  #  install --directory --mode 00700 \
  #  --owner ${user.name} --group ${user.group} \
  #  ${user.home}/.ssh
  #'';

  sops.secrets = {
    "user/ssh/private-key" = placeInHome ".ssh/id_ed25519";
    "user/ssh/public-key" = placeInHome ".ssh/id_ed25519.pub";
  };

  programs.ssh = {
    startAgent = true;
  };

  home-manager.users.sherex = { pkgs, ... }: {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      matchBlocks = {
        "github.com-test github.com github gh" = {
          hostname      = "github.com";
          user          = "git";
          identityFile  = "~/.ssh/id_ed25519";
        };
      };
    };

    programs.bash.shellAliases.ssh = "TERM=xterm-256color ssh";
  };
}





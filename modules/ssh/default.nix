{ config, pkgs, lib, home-manager, ... }:

let
  placeInHome = (user: path: {
    owner = config.users.users.${user}.name;
    path = "${config.users.users.${user}.home}/${toString path}";
  });
in
{
  sops.secrets = {
    "user/ssh/private-key" = placeInHome "sherex" ".ssh/id_ed25519";
    "user/ssh/public-key" = placeInHome "sherex" ".ssh/id_ed25519.pub";
  };

  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      openssh
    ];
    programs.bash.shellAliases.ssh = "TERM=xterm-256color ssh";
    # TODO: Use templating for inserting secrets
    home.file."./.ssh/config".text = ''
      Host github.com-test github.com github gh
        Hostname      github.com
        User          git
        IdentityFile  ~/.ssh/id_ed25519

      Host contabo
        Hostname      {{ssh.contabo.domain}}
        Port          {{ssh.contabo.port}}
        IdentityFile  ~/.ssh/id_ed25519
    '';
  };
}





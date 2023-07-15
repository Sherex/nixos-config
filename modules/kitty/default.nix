{ config, pkgs, lib, home-manager, ... }:

{
  imports = [ home-manager.nixosModule ];

  home-manager.users.sherex = { pkgs, ... }: {
    programs.bash.sessionVariables.TERMINAL = "kitty";
    programs.kitty = {
      enable = true;
      extraConfig = builtins.readFile (./. + "/kitty.conf");
    };
  };
}

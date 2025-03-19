{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex = { pkgs, ... }: {
    programs.bash.sessionVariables.TERMINAL = "kitty";
    programs.kitty = {
      enable = true;
      shellIntegration.enableBashIntegration = true;
      extraConfig = builtins.readFile (./. + "/kitty.conf");
    };
  };
}

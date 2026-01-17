{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex = { pkgs, ... }: {
    programs.yazi = {
      enable = true;
      keymap = {
        input.prepend_keymap = [
          # { run = "close"; on = [ "<c-q>" ]; }
        ];
        mgr.prepend_keymap = [
          { on  = [ "<C-n>" ]; run = "shell -- ${lib.getExe pkgs.ripdrag} %s -x 2>/dev/null &"; }
        ];
      };
    };
  };
}


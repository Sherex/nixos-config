{ config, pkgs, lib, home-manager, ... }:
{
  imports = [ home-manager.nixosModule ];

  home-manager.users.sherex = { pkgs, ... }: {
    # Keybinds for opening the tab in chromium
    programs.qutebrowser.keyBindings.normal = {
      "stc" = "spawn chromium {url}";
      "stC" = "spawn chromium --incognito {url}";
    };

    programs.librewolf = {
      # https://librewolf.net/docs/settings/
      enable = true;
      settings = {
        "webgl.disabled" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
      };
    };
  };
}


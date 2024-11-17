{ config, pkgs, lib, home-manager, home-manager-librewolf, ... }:
{
  imports = [
    home-manager.nixosModule
  ];

  home-manager.users.sherex = { pkgs, ... }: {
    disabledModules = [
      "programs/librewolf.nix"
    ];
    imports = [
      (home-manager-librewolf.outPath + "/modules/programs/librewolf.nix")
    ];
    # Keybinds for opening the tab in chromium
    programs.qutebrowser.keyBindings.normal = {
      "stc" = "spawn chromium {url}";
      "stC" = "spawn chromium --incognito {url}";
    };

    # Supports the same options as firefox: https://mynixos.com/home-manager/options/programs.firefox.profiles.%3Cname%3E
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


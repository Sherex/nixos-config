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
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      profiles.default.userChrome = ''
        @namespace url(http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul);

        #navigator-toolbox {
            height: 35px !important;
            min-height: 0px !important;
            overflow: hidden !important;
        }

        #navigator-toolbox:hover,
        #navigator-toolbox:focus,
        #navigator-toolbox:focus-within,
        #navigator-toolbox:active {
            height: auto !important;
            overflow: visible !important;
        }
      '';
    };
  };
}


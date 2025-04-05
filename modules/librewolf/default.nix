{ config, pkgs, lib, home-manager, ... }:
{
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
        "privacy.resistFingerprinting" = false;
        "privacy.fingerprintingProtection" = true;
        "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";
        "identity.fxaccounts.enabled" = true;
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


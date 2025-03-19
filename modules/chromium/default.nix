{ config, pkgs, lib, home-manager, ... }:
let
  createChromiumExtensionFor = browserVersion: { id, sha256, version }:
    {
      inherit id;
      crxPath = builtins.fetchurl {
        url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${browserVersion}&x=id%3D${id}%26installsource%3Dondemand%26uc";
        name = "${id}.crx";
        inherit sha256;
      };
      inherit version;
    };
  createChromiumExtension = createChromiumExtensionFor (lib.versions.major pkgs.ungoogled-chromium.version);
in
{
  home-manager.users.sherex = { pkgs, ... }: {
    # Keybinds for opening the tab in chromium
    programs.qutebrowser.keyBindings.normal = {
      "stc" = "spawn chromium {url}";
      "stC" = "spawn chromium --incognito {url}";
    };

    # Enable Wayland support in Chromium
    programs.bash.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [
        "--force-dark-mode"
        "--enable-features=WebUIDarkMode"
        "--ozone-platform-hint=auto"
      ];
      extensions =
        [
          (createChromiumExtension {
            # ublock origin
            id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
            sha256 = "sha256:0ib85l2vnpfa3dvalz7vxpw6q595qr1fmb5ai4d8zxwr1mlmvsrp";
            version = "1.50.0";
          })
          (createChromiumExtension {
            # dark reader
            id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
            sha256 = "sha256:106p3zqliyp7zbcnd3q8b11k606cy5rvi6bnvg4y2bwkynj55rsa";
            version = "4.9.64";
          })
          (createChromiumExtension {
            # Vimium - https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb
            id = "dbepggeogbaibhgnhhndojpepiihcmeb";
            sha256 = "sha256:0830rhd4rp1x5pn83cpnr8nmgr5za4v09676mm8gzk1a024yc661";
            version = "1.67.7";
          })
        ];
    };
  };
}


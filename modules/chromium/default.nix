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
  imports = [ home-manager.nixosModule ];

  home-manager.users.sherex = { pkgs, ... }: {
    programs.bash.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [
        "--force-dark-mode"
        "--enable-features=WebUIDarkMode"
      ];
      extensions =
        [
          (createChromiumExtension {
            # ublock origin
            id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
            sha256 = "sha256:08hq8blbmqz3kfs0mbhfpy8hkdwp0rvqi7aj8pgln76pmzfrd4q6";
            version = "1.50.0";
          })
          (createChromiumExtension {
            # dark reader
            id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
            sha256 = "sha256:106p3zqliyp7zbcnd3q8b11k606cy5rvi6bnvg4y2bwkynj55rsa";
            version = "4.9.64";
          })
        ];
    };
  };
}


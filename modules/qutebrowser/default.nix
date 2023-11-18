{ config, pkgs, lib, home-manager, ... }:

{
  imports = [ home-manager.nixosModule ];

  home-manager.users.sherex = { pkgs, ... }: {
    xdg.mimeApps.defaultApplications."text/html" = [ "org.qutebrowser.qutebrowser.desktop" ];
    programs.bash.sessionVariables.BROWSER = "qutebrowser";
    programs.qutebrowser = {
      enable = true;
      loadAutoconfig = true;
      aliases = { };
      keyBindings = {
        normal = {
          "<Ctrl+e>" = "edit-url";
          "D" = "tab-close -n";
          "E" = ":edit-text";
          "stf" = "spawn firefox {url}";
          "stm" = "spawn kdeconnec-cli -n 'Pixel 7' --share {url}";
          "stp" = "spawn mpv {url}";
          "<F1>" = lib.mkMerge [
            "config-cycle tabs.show never always"
            "config-cycle statusbar.show in-mode always"
            "config-cycle scrolling.bar never always"
          ];
        };
      };
      settings = {
        auto_save.session = true;
        completion.web_history.exclude = [ "file://tmp/aerc*" ];
        colors = {
          webpage = {
            darkmode.enabled = true;
            preferred_color_scheme = "dark";
          };
        };
        content = {
          autoplay = true;
          javascript.clipboard = "access";
          pdfjs = false;
        };
        # TODO: Insert correct terminal and editor commands based on current environment
        editor.command = [ "foot" "nvim" "-f" "{file}" "-c" "normal {line}G{column0}l" ];
        tabs = {
          background = false;
          new_position.unrelated = "next";
          position = "top";
          select_on_remove = "last-used";
          show = "always";
          show_switching_delay = 800;
        };
        scrolling.smooth = true;
      };
    };
  };
}


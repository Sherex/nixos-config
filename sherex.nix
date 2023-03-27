{ config, pkgs, lib, ... }:

{
  imports = [ <home-manager/nixos> ];

  # Install packages to /etc/profiles instead of ~/.nix-profile
  home-manager.useUserPackages = true;
  # Make home-manager use the global pkgs option
  home-manager.useGlobalPkgs = true;

  users.users.sherex = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      httpie
    ];
    programs.bash.enable = true;
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
	colors = {
	  webpage = {
	    darkmode.enabled = true;
	    preferred_color_scheme = "dark";
	  };
	};
	content = {
	  autoplay = true;
	  javascript.can_access_clipboard = true;
	  pdfjs = false;
	};
	editor.command = ["kitty" "nvim" "-f" "'{file}'" "-c" "normal {line}G{column0}l"];
	tabs = {
	  background = false;
	  new_position.unrelated = "next";
	  position = "top";
	  select_on_remove = "last-used";
	  show = "always";
	  show_switching_delay = 800;
	};
      };
    };
    programs.home-manager.enable = true;
  };
}

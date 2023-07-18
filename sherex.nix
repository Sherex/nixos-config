{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    home-manager.nixosModule
    ./modules/neovim
    ./modules/foot
  ];

  # Install packages to /etc/profiles instead of ~/.nix-profile
  home-manager.useUserPackages = true;
  # Make home-manager use the global pkgs option
  home-manager.useGlobalPkgs = true;

  # Enable bash-completion for system packages
  # https://nix-community.github.io/home-manager/options.html#opt-programs.bash.enableCompletion
  environment.pathsToLink = [ "/share/bash-completion" ];

  users.users.sherex = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  home-manager.users.sherex = { pkgs, ... }: {
    home.stateVersion = "22.11";
    home.packages = with pkgs; [
      httpie
      teams
      complete-alias # Alias completion for bash
    ];
    programs.bash = {
      enable = true;
      enableCompletion = true;
      profileExtra = lib.mkMerge [
      	# TODO: Move this to sway.nix by injecting to bash like home-manager does
        "sway"
      ];
      initExtra = lib.mkMerge [
	"source ${pkgs.complete-alias.outPath}/bin/complete_alias"
	"complete -F _complete_alias \"\${!BASH_ALIASES[@]}\""
	# BUG: The PS1 variable is overwritten somewhere if defined in sessionVariables
	"export PS1='\\[\\033[0;32m\\]\\[\\033[0m\\033[0;32m\\]\\h:\\[\\033[0;35m\\]\\w\\[\\033[0;32m\\]\\n\\[\\033[0m\\033[0;36m\\]\\[\\033[0m\\033[0;32m\\] ▶\\[\\033[0m\\] '"
      ];
      shellAliases = {
        ls = "ls --color=auto";
        dyff = "diff --color=auto --side-by-side";
        diff = "diff --color=auto --side-by-side --suppress-common-lines";
        e = "swaymsg exec ";
        snapc = "snapper create -t single -c timeline -d";
        lsblk = "lsblk -o NAME,MAJ:MIN,RM,FSTYPE,LABEL,SIZE,FSAVAIL,RO,MOUNTPOINT,UUID";
        mpv = "mpv --hr-seek=yes";
        cat = "bat";
        du = "dust";
        df = "duf";
        find = "fd";
        dig = "echo -e \"Other cmd: dog\\n\" && dig";
        htop = "echo -e \"Other cmd: btop\\n\" && htop";
        vim = "nvim";
        v = "vim ./";
        sc = "$EDITOR $HOME/.config/sway/config.d/";
        ssh = "TERM=xterm-256color ssh";
        serve = "miniserve --upload-files --mkdir --enable-tar-gz --enable-zip --show-wget-footer ";
        snapcp = "$HOME/.config/sway/scripts.d/snapshot-pre-post.sh";
        new-project = "curl -sSL https://github.com/Sherex/ts-template/raw/main/create.sh | bash -s ";

        ## Services mgmt
        sstart = "sudo systemctl start";
        sstatus = "sudo systemctl status";
        sstop = "sudo systemctl stop";
        srestart = "sudo systemctl restart";

        ## Git
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gcm = "git commit -m";
        gl = "git log";
        gcb = "git checkout -B";
        gd = "git diff";

        ## NixOS
        nos = "sudo nixos-rebuild --flake .# switch";
        nob = "sudo nixos-rebuild --flake .# build";
      };
      sessionVariables = {
        PS1 = "\\[\\033[0;32m\\]\\[\\033[0m\\033[0;32m\\]\\h:\\[\\033[0;35m\\]\\w\\[\\033[0;32m\\]\\n\\[\\033[0m\\033[0;36m\\]\\[\\033[0m\\033[0;32m\\] ▶\\[\\033[0m\\] ";
        EDITOR = "nvim";
        GUI_EDITOR = "code";
        VISUAL = "nvim";
        BROWSER = "qutebrowser";
        GTK_CSD = "0";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

        ## Locations
        USERSCRIPTS_CACHE = "$HOME/.cache/userscripts";
        PROJECTS_DIRECTORY = "$HOME/documents/git-reps";
      };
    };
    programs.git = {
      enable = true;
      # TODO: Use variables for name and email
      userName = "Ingar Helgesen";
      userEmail = "ingar@i-h.no";
    };
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
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
      ];
    };
    programs.home-manager.enable = true;
  };
}

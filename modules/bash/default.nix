{ config, pkgs, lib, home-manager, ... }:

let 
  miniservePort = 8080;
in
{
  # Enable bash-completion for system packages
  # https://nix-community.github.io/home-manager/options.html#opt-programs.bash.enableCompletion
  environment.pathsToLink = [ "/share/bash-completion" ];
  home-manager.users.sherex = { pkgs, ... }: {
    home.packages = with pkgs; [
      ripgrep
      fd
      bat
      miniserve
    ];
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoredups" "erasedups" ];
      initExtra = lib.mkMerge [
        "source ${pkgs.complete-alias.outPath}/bin/complete_alias"
        "complete -F _complete_alias \"\${!BASH_ALIASES[@]}\""
        # BUG: The PS1 variable is overwritten somewhere if defined in sessionVariables
        "export PS1='\\[\\033[0;32m\\]\\[\\033[0m\\033[0;32m\\]\\h:\\[\\033[0;35m\\]\\w\\[\\033[0;32m\\]\\n\\[\\033[0m\\033[0;36m\\]\\[\\033[0m\\033[0;32m\\] ▶\\[\\033[0m\\] '"
        "# Script to more easily run arbitary packages from nixpkgs"
        "# Execute 'nr -h' for more info"
        "source ${ ./scripts/nix-run-pkgs.sh }"
      ];
      shellAliases = {
        ls = "ls --color=auto";
        dyff = "diff --color=auto --side-by-side";
        diff = "diff --color=auto --side-by-side --suppress-common-lines";
        snapc = "snapper create -t single -c timeline -d";
        lsblk = "lsblk -o NAME,MAJ:MIN,RM,FSTYPE,LABEL,SIZE,FSAVAIL,RO,MOUNTPOINT,UUID";
        mpv = "mpv --hr-seek=yes";
        cat = "bat";
        find = "fd";
        dig = "echo -e \"Other cmd: dog\\n\" && dig";
        htop = "echo -e \"Other cmd: btop\\n\" && htop";
        vim = "nvim";
        v = "vim ./";
        serve = "${pkgs.miniserve}/bin/miniserve --port ${toString miniservePort} --upload-files --mkdir --enable-tar-gz --enable-zip --show-wget-footer ";
        snapcp = "$HOME/.config/sway/scripts.d/snapshot-pre-post.sh";
        new-project = "curl -sSL https://github.com/Sherex/ts-template/raw/main/create.sh | bash -s ";

        ## Shortcuts
        ec = "$EDITOR -S /etc/nixos/Session.vim";

        ## Reboot options
        arch = "sudo ${pkgs.grub2.outPath}/bin/grub-reboot 'Arch Linux' && reboot";
        winshit = "sudo ${pkgs.grub2.outPath}/bin/grub-reboot 'WinShit' && reboot";

        ## Services mgmt
        sstart = "sudo systemctl start";
        sstatus = "sudo systemctl status";
        sstop = "sudo systemctl stop";
        srestart = "sudo systemctl restart";

        ## NixOS
        nos = "sudo nixos-rebuild --flake .# switch";
        nob = "sudo nixos-rebuild --flake .# build";
      };
      sessionVariables = {
        PS1 = "\\[\\033[0;32m\\]\\[\\033[0m\\033[0;32m\\]\\h:\\[\\033[0;35m\\]\\w\\[\\033[0;32m\\]\\n\\[\\033[0m\\033[0;36m\\]\\[\\033[0m\\033[0;32m\\] ▶\\[\\033[0m\\] ";
        PROMPT_COMMAND = "history -a; history -n";
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
    programs.fzf = {
      enable = true;
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [
        "--preview 'head {}'"
      ];
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [
        "--preview '${pkgs.tree}/bin/tree -C {} | head -200'"
      ];
      colors = {
        "fg" = "#3dab1b";
        "fg+" = "#ff00b7";
        "info" = "#87afaf";
        "prompt" = "#d7005f";
        "pointer" = "#ff00b7";
        "marker" = "#87ff00";
        "spinner" = "#ff00b7";
        "header" = "#87afaf";
      };
      defaultCommand = "fd --type f";
      defaultOptions = [
        "--height 40%"
        "--border"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ miniservePort ];
}


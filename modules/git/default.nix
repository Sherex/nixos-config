{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex = {
    programs.git = {
      enable = true;
      # TODO: Use variables for name and email
      settings = {
        user.name = "Ingar Helgesen";
        user.email = "ingar@i-h.no";
        column.ui = "auto";
        branch.sort = "-committerdate";
        tag.sort = "version:refname";
        init.defaultBranch = "main";
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };
        fetch = {
          all = true;
        };
        help.autocorrect = "prompt";
        commit.verbose = true;
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        merge = {
          conflictstyle = "zdiff3";
        };
        pull = {
          rebase = true;
        };
      };
    };
    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = lib.mkMerge [
        "# Command for easier selection of git commits using fzf"
        "source ${ ./scripts/git-select-commit.sh }"
        "# Wrapper command to add functionality to git commands"
        "source ${ ./scripts/git-wrapper.sh }"
      ];
      shellAliases = {
        gs = "git status";
        ga = "git add";
        gap = "git add --patch";
        grbase = "git rebase --interactive --autosquash";
        gr = "git restore --patch";
        grs = "git restore --patch --staged";
        gc = "git commit";
        gcm = "git commit -m";
        gca = "git commit --amend";
        gcf = "git commit --fixup={}";
        gp = "git push";
        gl = "git log";
        gcb = "git checkout -B";
        gd = "git diff";
        gds = "git diff --staged";
      };
    };
  };
}

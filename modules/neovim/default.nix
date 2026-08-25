{ config, pkgs, lib, home-manager, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home-manager.users.sherex = { pkgs, ... }: {
    home.file."./.config/nvim/" = {
      source = ./config;
      recursive = true;
    };
    home.file.".config/nvim/after/queries/nix/injections.scm".text = /* scheme */ ''
      ;; extends

      ;; Inject a language via comment preceding a string
      ;; Examples:
      ;;   /* lua */ "..."
      ;;   /* bash */ \'\'...\'\'

      ;; Regular double-quoted strings: "..."
      (
        (comment) @_comment
        .
        (string_expression) @injection.content
        (#lua-match? @_comment "^/%*%s*[a-zA-Z0-9_-]+%s*%*/$")
        (#offset! @injection.content 0 1 0 -1)
        (#set! injection.combined)
        (#gsub! @_comment "^/%*%s*" "")
        (#gsub! @_comment "%s*%*/$" "")
        (#set! injection.language @_comment)
      )

      ;; Indented strings: \'\'...\'\'
      (
        (comment) @_comment
        .
        (indented_string_expression) @injection.content
        (#lua-match? @_comment "^/%*%s*[a-zA-Z0-9_-]+%s*%*/$")
        (#offset! @injection.content 0 2 0 -2)
        (#set! injection.combined)
        (#gsub! @_comment "^/%*%s*" "")
        (#gsub! @_comment "%s*%*/$" "")
        (#set! injection.language @_comment)
      )
    '';

    programs.bash.initExtra = lib.mkMerge [
      # A workaround for terminals in Neovim to use when inside a nix devshell
      "export NVIM_SYSTEM_SHELL=$SHELL"
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withRuby = false;
      withPython3 = false;
      withNodeJs = false;
      withPerl = false;
      extraPackages = with pkgs; [
        gcc # Treesitter dependency
        tree-sitter # Treesitter dependency
        nodejs # Treesitter dependency
        lua-language-server # LSP
        nil # LSP: nix
        vscode-langservers-extracted # LSP: json, yaml
        terraform-lsp # LSP
        typescript # LSP: tsserver
        typescript-language-server # LSP: tsserver
        yaml-language-server # LSP: yamlls
        bash-language-server # LSP: bash
        shellcheck # linter for shell scripts
        lemminx # LSP: XML
        pyright # LSP: Python
        haskell-language-server # LSP: Haskell
        rust-analyzer # LSP: Rust
      ];
    };
  };
}

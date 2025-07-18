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

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      extraPackages = with pkgs; [
        gcc # Treesitter dependency
        tree-sitter # Treesitter dependency
        nodejs # Treesitter dependency
        lua-language-server # LSP
        nil # LSP: nix
        vscode-langservers-extracted # LSP: json, yaml
        terraform-lsp # LSP
        nodePackages.typescript # LSP: tsserver
        nodePackages.typescript-language-server # LSP: tsserver
        yaml-language-server # LSP: yamlls
        nodePackages.bash-language-server # LSP: bash
        shellcheck # linter for shell scripts
        lemminx # LSP: XML
        pyright # LSP: Python
        haskell-language-server # LSP: Haskell
      ];
    };
  };
}

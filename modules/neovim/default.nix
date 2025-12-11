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

    programs.bash.initExtra = lib.mkMerge [
      # A workaround for terminals in Neovim to use when inside a nix devshell
      "export NVIM_SYSTEM_SHELL=$SHELL"
    ];

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

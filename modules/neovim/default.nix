{ config, pkgs, lib, home-manager, ... }:

{
  imports = [ home-manager.nixosModule ];

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
        nil # LSP
        vscode-langservers-extracted # LSP
        terraform-lsp # LSP
        nodePackages.typescript # LSP: tsserver
        nodePackages.typescript-language-server # LSP: tsserver
      ];
    };
  };
}

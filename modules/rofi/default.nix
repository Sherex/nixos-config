{ config, pkgs, lib, home-manager, ... }:

{
  imports = [ home-manager.nixosModule ];

  # TODO: Add sway keybinds directly
  home-manager.users.sherex = { pkgs, ... }: {
    programs.rofi = {
      enable = true;
      font = "hack 10";
      terminal = "${config.home-manager.users.sherex.programs.bash.sessionVariables.TERMINAL}";
      theme = toString ./themes/default/iceberg-dark.rasi;
      extraConfig = {
        modi = "combi";
        show-icons = true;
        ssh-command = "{terminal} -e {ssh-client} {host} [-p {port}]";
	      combi-modi = "drun,ssh";
      };
      plugins = with pkgs; [
        rofi-calc
      ];
    };
    home.packages = with pkgs; [
      # TODO: When sway is configured using home-manager,
      #       then enable rofi-bluetooth in the bluetooth module
      rofi-bluetooth
    ];
  };
}


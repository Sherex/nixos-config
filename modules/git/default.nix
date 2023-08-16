{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex.programs.git = {
    enable = true;
    # TODO: Use variables for name and email
    userName = "Ingar Helgesen";
    userEmail = "ingar@i-h.no";
  };
}


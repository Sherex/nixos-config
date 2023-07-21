{ config, pkgs, lib, home-manager, ... }:

{
  sops.secrets."user/email/password" = {
    owner = config.users.users.sherex.name;
    group = config.users.users.sherex.group;
  };

  home-manager.users.sherex = { pkgs, ... }: {
    programs.mu.enable = true;
    programs.aerc = {
      enable = true;
      extraConfig = {
        general.unsafe-accounts-conf = true;
        compose = {
          header-layout = "To|From,CC|BCC,Subject";
          #file-picker-cmd = "";
          no-attachment-warning = "^[^>]*(attach(ed|ment))|(ved(lagt|legg))";
        };
        multipart-converters."text/html" = "${pkgs.pandoc}/bin/pandoc -f markdown -t html --standalone";
        filters = {
          "text/plain" = "colorize";
          "text/calendar" = "calendar";
          "message/delivery-status" = "colorize";
          "message/rfc822" = "colorize";
          "text/html" = "${pkgs.pandoc}/bin/pandoc -f html -t plain | colorize";
          ".headers" = "colorize";
        };
        hooks = {
          mail-received=''${pkgs.libnotify}/bin/notify-send "New mail from $AERC_FROM_NAME" "$AERC_SUBJECT"'';
        };
      };
    };
    accounts.email.accounts = {
      main = {
        primary = true;
        address = "ingar@i-h.no";
        userName ="ingar@i-h.no";
        realName = "Ingar Helgesen";
        passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."user/email/password".path}";
        aerc.enable = true;
        imap = {
          host = "imap.fastmail.com";
        };
        smtp = {
          host = "smtp.fastmail.com";
          tls.enable = true;
        };
      };
    };
  };
}




{ config, pkgs, lib, home-manager, ... }:

let
  background_image = {
    path = "$HOME/media/images/backgrounds/current.img";
  };
  binaries = {
    hyprlock = "${pkgs.hyprlock.outPath}/bin/hyprlock";
  };
in {
  imports = [
    ../waybar
  ];

  environment.systemPackages = with pkgs; [
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    adwaita-icon-theme # default gnome cursors
    grim # screenshot functionality
    slurp # screenshot functionality
    swappy # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wl-gammarelay-rs # Used by a block in i3status-rust
    complete-alias
  ];

  fonts.packages = with pkgs; [
    font-awesome_5
    nerd-fonts.hack
  ];

  services.dbus.enable = true;

  # Autostart Hyprland on login
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && ${pkgs.hyprland}/bin/start-hyprland
  '';
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Hint Electron apps to use Wayland
    GTK_USE_PORTAL = "1"; # Not recommended, but fuck it. It's recommended to set it per application instead
    XCURSOR_THEME = "Vanilla-DMZ";
  };

  programs.hyprland.enable = true;

  home-manager.users.sherex = { pkgs, ... }: {
    # Default to allow re-using screen sharing token.
    # (ie. applications only need to ask once when first showing a preview of the screen)
    xdg.configFile."hypr/xdph.conf".text = ''
      allow_token_by_default = true
    '';

    # xdg-desktop-portal works by exposing a series of D-Bus interfaces
    # known as portals under a well-known name
    # (org.freedesktop.portal.Desktop) and object path
    # (/org/freedesktop/portal/desktop).
    # The portal interfaces include APIs for file access, opening URIs,
    # printing and others.
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        # gtk portal needed to make gtk apps happy
        common.default = [ "gtk" "hyprland" ];
        common."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-termfilechooser
      ];
    };

    xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
      default_dir=$HOME
      env=TERMCMD='${lib.getExe pkgs.foot}'
      open_mode=suggested
      save_mode=last
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      settings = {
        config = {
          general = {
            gaps_in = 5;
            gaps_out = 20;

            border_size = 2;

            # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
            col = {
              active_border.colors = [ "rgba(33ccffee)" "rgba(00ff99ee)"];
              active_border.angle = 45;
              inactive_border = "rgba(595959aa)";
            };

            # Set to true enable resizing windows by clicking and dragging on borders and gaps
            resize_on_border = false;

            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false;

            layout = "dwindle";
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };

          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };

          decoration = {
            rounding = 0;

            # Change transparency of focused and unfocused windows
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
              enabled = false;
            };

            # https://wiki.hyprland.org/Configuring/Variables/#blur
            blur = {
              enabled = false;
              size = 3;
              passes = 1;

              vibrancy = 0.1696;
            };
          };

          # https://wiki.hyprland.org/Configuring/Variables/#animations
          animations = {
            enabled = false;
          };

          # https://wiki.hyprland.org/Configuring/Dwindle-Layout/
          dwindle = {
            preserve_split = true;
          };

          # https://wiki.hyprland.org/Configuring/Master-Layout/
          master = {
            new_status = "master";
          };

          # https://wiki.hyprland.org/Configuring/Variables/#input
          input = {
            kb_layout = "no";
            follow_mouse = 1;
            touchpad.disable_while_typing = false;
          };

          debug = {
            disable_logs = false;
          };
        };

      };

      extraConfig = let
        variables = {
          mainMod = "SUPER";
          terminal = "${pkgs.foot}/bin/foot";
          fileManager = "${pkgs.yazi}/bin/yazi";
          menu = "${pkgs.rofi}/bin/rofi -modes combi -show combi";
          ssh_menu = "${pkgs.rofi}/bin/rofi -modes ssh -show ssh";
          playerctl = "${pkgs.playerctl}/bin/playerctl";
          wpctl = "${pkgs.wireplumber}/bin/wpctl";
          hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
          btop = "${pkgs.btop}/bin/btop";
          start_hyperland = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target";
        };

        # Convert the Nix set to a string of Lua 'local' declarations
        luaVariables = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: value: "local ${name} = [[${value}]]") variables
        );
      in ''
        ${luaVariables}
        ${builtins.readFile ./hyprland.lua}
      '';
    };

    services.mako = {
      enable = true;
      settings = {
        font = "monospace 10";
        width = 300;
        height = 100;
        margin = "10";
        padding = "5";
        progress-color = "over #5588AAFF";
        background-color = "#000000";
        text-color = "#00FF00";
        border-color = "#00FF00";
        border-size = 1;
        border-radius = 0;
        icons = true;
        max-icon-size = 64;
        markup = true;
        default-timeout = 10000;
      };
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        wallpaper = {
          monitor = "";
          path = background_image.path;
        };
      };
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 300;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            # BUG: Doesn't take a screenshot, no error logged
            #path = "screenshot";
            path = background_image.path;
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = ''
              '<span foreground="##cad3f5">Password...</span>'
            '';
            shadow_passes = 2;
          }
        ];
      };
    };

    services.hypridle = {
      enable = true;
      settings = let
          earlylockfile = "$XDG_RUNTIME_DIR/hyprlock-early.lock";
        in {
        general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = binaries.hyprlock;
            on_lock_cmd = "touch ${earlylockfile}";
          };

          listener = [
            {
              timeout = 30;
              condition_cmd = "[[ -f '${earlylockfile}' ]]";
              on-timeout = "hyprctl eval \"hl.dispatch(hl.dsp.dpms({ action = 'disable' }))\"";
              on-resume = "hyprctl eval \"hl.dispatch(hl.dsp.dpms({ action = 'enable' }))\" && rm -f ${earlylockfile}";
            }
            {
              timeout = 900;
              on-timeout = binaries.hyprlock;
            }
            {
              timeout = 1200;
              on-timeout = "hyprctl eval \"hl.dispatch(hl.dsp.dpms({ action = 'disable' }))\"";
              on-resume = "hyprctl eval \"hl.dispatch(hl.dsp.dpms({ action = 'enable' }))\"";
            }
          ];
      };
    };
  };

  systemd.user.services.hyprland-tagger-mover = {
    enable = true;
    description = "A utility service for hyprland to tag and move windows launched from specific directories.";
    after = [ "hyprland-session.target" ];
    wantedBy = [ "default.target" "hyprland-session.target" ];
    unitConfig = {
      StartLimitIntervalSec = 10;
    };
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 3;
      StartLimitBurst = 3;
    };
    path = with pkgs; [ bash jq hyprland socat ];
    script = ''
      [[ -z $XDG_RUNTIME_DIR ]] && echo "Missing required env variable: XDG_RUNTIME_DIR" && exit 1
      [[ -z $HYPRLAND_INSTANCE_SIGNATURE ]] && echo "Missing required env variable: HYPRLAND_INSTANCE_SIGNATURE" && exit 1

      [[ -f "$XDG_RUNTIME_DIR/services/hyprland-tagger-mover.debug" ]] && DEBUG=1

      # Declare the TAGS associative array with space-separated directories as values
      declare -A TAGS
      TAGS=(
          ["game"]="/persistent/unsafe/games/ /media/storage/games/"
      )

      # Associative array to define which assigs tags to workspaces and
      # is used to move the window to that workspace
      declare -A TAGS2WORKSPACES
      TAGS2WORKSPACES=(
          ["game"]="2"
      )

      # Function to check if a path is in any of the directories for a specific tag
      path_is_in() {
          local target_path="$1"
          local tag="$2"

          # Loop through directories for the given tag (split by space)
          for dir in ''${TAGS[$tag]}; do
              if [[ "$target_path" == "$dir"* ]]; then
                  return 0  # Path matches this tag's directory
              fi
          done
          return 1  # Path does not match
      }

      EVENT_SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

      echo "Listening on: $EVENT_SOCKET"
      socat -U - "UNIX-CONNECT:$EVENT_SOCKET" | while read -r line; do
          [[ "$line" != openwindow* ]] && continue

          # Extract event name and data
          window_address="0x$(echo "$line" | sed -E 's/^.*?>>(\w+),.*/\1/')"
          window="$(hyprctl clients -j | jq --arg window_address "$window_address" '.[] | select(.address == $window_address)')"

          pid="$(echo "$window" | jq -r '.pid')"
          window_title="$(echo "$window" | jq -r '.title')"

          proc_path=$(readlink -f "/proc/$pid/exe" 2>/dev/null)

          [[ $DEBUG = 1 ]] && echo "[D] Window \"$window_title\" was created with process [pid: $pid] from $proc_path"

          # Check each tag and see if the process path matches the directories for that tag
          for tag in "''${!TAGS[@]}"; do
              if path_is_in "$proc_path" "$tag"; then
                  hyprctl dispatch tagwindow "+$tag" "pid:$pid"
                  echo "Tagged window '$window_title' from $proc_path as $tag"

                  # Stop if there are no workspaces assigned to this tag
                  assigned_workspace=''${TAGS2WORKSPACES[$tag]}
                  [[ -z $assigned_workspace ]] && break

                  hyprctl dispatch movetoworkspacesilent "$assigned_workspace,address:$window_address"
                  echo "Moved window '$window_title' to workspace $assigned_workspace"
                  break
              fi
          done

      done
    '';
  };
}


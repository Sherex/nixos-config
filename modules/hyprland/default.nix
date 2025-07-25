{ config, pkgs, lib, home-manager, ... }:

let
  background_image = {
    path = "$HOME/media/images/backgrounds/current.img";
  };
  binaries = {
    hyprlock = "${pkgs.hyprlock.outPath}/bin/hyprlock";
  };
  duplicate-terminal = pkgs.writeShellScript "duplicate-terminal" ''
    #!/usr/bin/env bash
    active_pid=$(hyprctl activewindow -j | jq -r '.pid')
    bash_pid=$(pgrep -lP "$active_pid" | awk '$2 ~ /^(bash|zsh|fish|sh)$/ { print $1 }')
    NOTIFY_CMD="${pkgs.libnotify}/bin/notify-send -u normal"

    if [ -z "$bash_pid" ] || [ ! -d "/proc/$bash_pid/cwd" ]; then
        $NOTIFY_CMD "Error" "Could not determine shell CWD from active window"
        exit 1
    fi

    cwd=$(realpath "/proc/$bash_pid/cwd")
    hyprctl dispatch exec -- foot -D "$cwd"
  '';
in {
  imports = [
    ../waybar
  ];

  environment.systemPackages = with pkgs; [
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    dracula-theme # gtk theme
    adwaita-icon-theme # default gnome cursors
    grim # screenshot functionality
    slurp # screenshot functionality
    swappy # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wl-gammarelay-rs # Used by a block in i3status-rust
    complete-alias
    btop # Top alt.
  ];

  fonts.packages = with pkgs; [
    font-awesome_5
    nerd-fonts.hack
  ];

  services.dbus.enable = true;

  # Autostart Hyprland on login
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && ${pkgs.hyprland}/bin/Hyprland
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
        common.default = ["gtk" "hyprland"];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
    };

    wayland.windowManager.hyprland = {
      enable = true;
      plugins = [
        pkgs.hyprlandPlugins.hy3
      ];
      settings = {
        "$terminal" = "${pkgs.foot}/bin/foot";
        "$duplicate-terminal" = "${duplicate-terminal}";
        "$menu" = "${pkgs.rofi-wayland}/bin/rofi -modes combi -show combi";
        "$ssh-menu" = "${pkgs.rofi-wayland}/bin/rofi -modes ssh -show ssh";
        "$playerctl" = "${pkgs.playerctl}/bin/playerctl";
        "$wpctl" = "${pkgs.wireplumber}/bin/wpctl";

        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

        monitor = [
          ",preferred,auto,1"
          "Unknown-1,disable"
        ];

        exec-once = [
          "$terminal"
          "[workspace special:monitoring silent] $terminal ${pkgs.btop}/bin/btop"
          "[workspace special:monitoring silent] $terminal nvtop"
        ];

        general = { 
          gaps_in = 5;
          gaps_out = 20;

          border_size = 2;

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false;

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;

          layout = "hy3";
        };

        plugin = {
          hy3 = {
            tabs = {
              borderWidth = 1;
              col_active = "rgba(33ccff20)";
              col_active_border = "rgba(33ccffee)";
              col_inactive = "rgba(30303020)";
              col_inactive_border = "rgba(595959aa)";
              col_urgent = "rgba(ff223340)";
              col_urgent_border = "rgba(ff2233ee)";
            };

            autotile = {
              enable = true;
              triggerWidth = 800;
              triggerHeight = 500;
            };
          };
        };

        cursor = {
          hide_on_key_press = true;
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
          pseudotile = true;
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


        # See https://wiki.hyprland.org/Configuring/Keywords/
        "$mainMod" = "SUPER";
        bind = [
          # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          "$mainMod, return, exec, $terminal"
          "$mainMod CTRL, return, exec, $duplicate-terminal"
          "$mainMod SHIFT, return, exec, $ssh-menu"
          "$mainMod, Q, killactive,"
          "$mainMod SHIFT, END, exit,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod SHIFT, V, togglefloating,"
          "$mainMod, V, cyclenext, floating"
          "$mainMod, F, fullscreen, 1"
          "$mainMod SHIFT, F, fullscreen, 0"
          "$mainMod, D, exec, $menu"
          "$mainMod, P, pseudo,"
          "$mainMod, W, togglesplit,"

          # Screen-lock
          "$mainMod, Z, exec, ${binaries.hyprlock}"

          # Move focus
          "$mainMod, h, hy3:movefocus, l"
          "$mainMod, l, hy3:movefocus, r"
          "$mainMod, k, hy3:movefocus, u"
          "$mainMod, j, hy3:movefocus, d"

          # Move windows
          "$mainMod SHIFT, h, hy3:movewindow, l"
          "$mainMod SHIFT, l, hy3:movewindow, r"
          "$mainMod SHIFT, k, hy3:movewindow, u"
          "$mainMod SHIFT, j, hy3:movewindow, d"

          # Hy3 (https://github.com/outfoxxed/hy3#dispatcher-list)
          "$mainMod SHIFT, R, hy3:changegroup, opposite"
          "$mainMod SHIFT, W, hy3:changegroup, toggletab"
          "$mainMod CTRL, j, hy3:makegroup, v, toggle, force_ephemeral"
          "$mainMod CTRL, h, hy3:makegroup, h, toggle, force_ephemeral"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
          "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
          "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
          "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
          "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
          "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
          "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
          "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
          "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
          "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

          # Scratchpad
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspacesilent, special:magic"

          # Monitoring workspace
          "$mainMod, M, togglespecialworkspace, monitoring"
          "$mainMod SHIFT, M, movetoworkspacesilent, special:monitoring"

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          # Screenshot
          ", Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
          "CTRL, Print, exec, grim -g \"$(slurp -o)\" - | swappy -f -"
        ];

        binde = [
          # Media controls
          ",XF86AudioStop, exec, $playerctl stop"
          ",XF86AudioPlay, exec, $playerctl play-pause"
          ",XF86AudioNext, exec, $playerctl next"
          ",XF86AudioPrev, exec, $playerctl previous"

          ",XF86AudioRaiseVolume, exec, $wpctl set-volume @DEFAULT_SINK@ 2%+"
          ",XF86AudioLowerVolume, exec, $wpctl set-volume @DEFAULT_SINK@ 2%-"
          ",XF86AudioMute, exec, $wpctl set-mute @DEFAULT_SINK@ toggle"
        ];

        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, hy3:movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        workspace = [
          "w[tv1], gapsout:0, gapsin:0" # Smart gaps: https://wiki.hyprland.org/Configuring/Workspace-Rules/#smart-gaps
          "f[1], gapsout:0, gapsin:0" # Smart gaps
        ];

        windowrulev2 = [
          "suppressevent maximize, class:.*"
          "stayfocused, title:.*(rofi).*"
          "bordersize 0, floating:0, onworkspace:w[tv1]" # Smart gaps
          "rounding 0, floating:0, onworkspace:w[tv1]" # Smart gaps
          "bordersize 0, floating:0, onworkspace:f[1]" # Smart gaps
          "rounding 0, floating:0, onworkspace:f[1]" # Smart gaps
        ];

        debug = {
          disable_logs = false;
        };
      };

      extraConfig = ''
        # Resize windows
        bind = $mainMod, R, submap, resize

        submap = resize
        binde = $mainMod, h, resizeactive, -20 0
        binde = $mainMod, l, resizeactive, 20 0
        binde = $mainMod, k, resizeactive, 0 -20
        binde = $mainMod, j, resizeactive, 0 20

        binde = $mainMod SHIFT, h, resizeactive, -200 0
        binde = $mainMod SHIFT, l, resizeactive, 200 0
        binde = $mainMod SHIFT, k, resizeactive, 0 -200
        binde = $mainMod SHIFT, j, resizeactive, 0 200

        bind = , escape, submap, reset
        submap = reset
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
        preload = [
          background_image.path
        ];
        wallpaper = [
          ",${background_image.path}"
        ];
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
          };

          listener = [
            {
              timeout = 30;
              on-timeout = "pidof hyprlock && hyprctl dispatch dpms off && touch ${earlylockfile}";
              on-resume = "[[ -f '${earlylockfile}' ]] && hyprctl dispatch dpms on && rm ${earlylockfile}";
            }
            {
              timeout = 900;
              on-timeout = binaries.hyprlock;
            }
            {
              timeout = 1200;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
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

      # Declare the TAGS associative array with space-separated directories as values
      declare -A TAGS
      TAGS=(
          ["game"]="/persistent/unsafe/games/ /mnt-d/games"
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


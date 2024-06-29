{ config, pkgs, lib, home-manager, ... }:

let
  background_image = {
    path = "$HOME/media/images/backgrounds/current.img";
  };
  binaries = {
    hyprlock = "${pkgs.hyprlock.outPath}/bin/hyprlock";
  };
in {
  environment.systemPackages = with pkgs; [
    xdg-utils # for opening default programs when clicking links
    glib # gsettings
    dracula-theme # gtk theme
    gnome3.adwaita-icon-theme # default gnome cursors
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wl-gammarelay-rs # Used by a block in i3status-rust
    complete-alias
    btop # Top alt.
  ];

  fonts.packages = with pkgs; [
    font-awesome_5
    # Note: Not sure if this works as I can't figure out how to clean the local cache.
    #       Tried nix-collect-garbage -d and deleting /root/.cache/nix
    # TODO: Figure out how to use non-monospaced font for Symbols
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Autostart Hyprland on login
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && hyprland
  '';

  home-manager.users.sherex = { pkgs, ... }: {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$terminal" = "${pkgs.foot}/bin/foot";
        "$menu" = "${pkgs.rofi-wayland}/bin/rofi -show combi";

        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

        monitor = [
          ",preferred,auto,auto"
          "Unknown-1,disable"
        ];

        exec-once = [
          "$terminal"
          "[workspace special:monitoring silent] $terminal ${pkgs.btop}/bin/btop"
          "[workspace special:monitoring silent] $terminal ${pkgs.nvtopPackages.nvidia}/bin/nvtop"
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

          layout = "dwindle";
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        decoration = {
          rounding = 10;

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur = {
            enabled = true;
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
        };


        # See https://wiki.hyprland.org/Configuring/Keywords/
        "$mainMod" = "SUPER";
        bind = [
          # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          "$mainMod, return, exec, $terminal"
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

          # Move focus
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          # Move windows
          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, j, movewindow, d"

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

        ];

        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        windowrulev2 = [
          "suppressevent maximize, class:.*"
          "stayfocused, title:.*(rofi).*"
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
      settings = {
        general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = binaries.hyprlock;
          };

          listener = [
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
}


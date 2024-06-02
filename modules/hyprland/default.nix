{ config, pkgs, lib, home-manager, ... }:

let
  background_image = {
    path = "~/media/images/backgrounds/current.img";
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
    rofi-wayland # wayland clone of dmenu
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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

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

  home-manager.users.sherex = { pkgs, ... }: {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$terminal" = "foot";
        "$menu" = "rofi -show combi";

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
          new_is_master = true;
        };

        # https://wiki.hyprland.org/Configuring/Variables/#input
        input = {
          kb_layout = "no";
          follow_mouse = 3;
        };


        # See https://wiki.hyprland.org/Configuring/Keywords/
        "$mainMod" = "SUPER";
        bind = [
          # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          "$mainMod, return, exec, $terminal"
          "$mainMod, Q, killactive,"
          "$mainMod SHIFT, Q, exit,"
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
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          # Example special workspace (scratchpad)
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"

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
        ];
      };
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
  };
}


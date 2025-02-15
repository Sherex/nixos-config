{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex = { pkgs, ... }: {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };
      # https://github.com/Alexays/Waybar/wiki
      settings = [{
        layer = "top";
        position = "top";
        height = 24;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" "idle_inhibitor" "pulseaudio" "backlight" "network" "custom/updates" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "hyprland/submap" "hyprland/language" "cpu" "memory" "temperature" "battery" "tray" "clock" ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch workspace m-1 > /dev/null";
          on-scroll-down = "hyprctl dispatch workspace m+1 > /dev/null";
          format = "{name}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            urgent = "";
            focused = "";
            default = "";
          };
        };
        "keyboard-state" = {
          numlock = false;
          capslock = false;
          format = "{name} {icon}";
          format-icons = {
            locked = "";
            unlocked = "";
          };
        };
        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
        };
        "hyprland/language" = {
          format = "{}";
          max-length = 18;
        };
        "clock" = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
        };
        "cpu" = {
          format = "{usage}% ";
          tooltip = false;
        };
        "memory" = {
          format = "{}% ";
        };
        "temperature" = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" ];
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 🗲";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        "network" = {
          format-wifi = "{essid} ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        "pulseaudio" = {
          format = "{volume}%{icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };
      }];
      style = ''
        * {
            font-family: monospace;
            font-size: 12px;
            text-shadow: none;
        }

        window#waybar {
            background-color: #000000;
            border-bottom: 1px solid #444;
            color: #00ff00;
            transition: none;
        }

        window#waybar.hidden {
            opacity: 0.2;
        }

        button {
            border: none;
            background: none;
            color: #00ff00;
        }

        button:hover {
            background: none;
            text-decoration: underline;
        }

        #workspaces button {
            padding: 0 5px;
            background-color: transparent;
            color: #00ff00;
        }

        #workspaces button:hover {
            background: #222;
        }

        #workspaces button.focused {
            background-color: #005500;
            text-decoration: underline;
        }

        #workspaces button.urgent {
            background-color: #550000;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #wireplumber,
        #custom-media,
        #tray,
        #mode,
        #idle_inhibitor,
        #scratchpad,
        #power-profiles-daemon,
        #mpd {
            padding: 0 10px;
            color: #00ff00;
            background: none;
        }

        #battery.charging, #battery.plugged {
            color: #000000;
            background-color: #00ff00;
        }

        @keyframes blink {
            to {
                color: #ff0000;
            }
        }

        #battery.critical:not(.charging) {
            color: #ff0000;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: steps(2);
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #cpu {
            color: #ffcc00;
        }

        #memory {
            color: #cc66ff;
        }

        #disk {
            color: #ffaa00;
        }

        #network {
            color: #6699ff;
        }

        #network.disconnected {
            color: #ff0000;
        }

        #pulseaudio {
            color: #ffff00;
        }

        #pulseaudio.muted {
            color: #777777;
        }

        #temperature {
            color: #ff6600;
        }

        #temperature.critical {
            color: #ff0000;
        }

        #tray {
            color: #66ccff;
        }

        #idle_inhibitor.activated {
            color: #ffffff;
            background: #222;
        }

        #mpd.paused {
            color: #33cc33;
        }
      '';
    };
  };
}


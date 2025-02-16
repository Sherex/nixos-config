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
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "idle_inhibitor" "pulseaudio" "network" "custom/vpn" "cpu" "memory" "temperature" "battery" "tray" "clock" ];
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
        "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
                activated = "";
                deactivated = "";
            };
        };
        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
        };
        clock = {
          interval = 1;
          format = "{:%a. %b. %d. %H:%M:%S }";
          format-alt = "{:%A, %B %d, %Y (%R)}  ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        "cpu" = {
          format = "{usage}% ";
          tooltip = true;
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
        "custom/vpn" = {
          exec = pkgs.writeShellScript "vpn_status.sh" ''
            response=$(curl -s https://ipv4.am.i.mullvad.net/json)

            if echo "$response" | grep -Eq '"mullvad_exit_ip":\s*true'; then
              echo '{"text": "VPN:🔒 ", "class": "connected"}'
            else
              echo '{"text": "VPN:❌ ", "class": "disconnected"}'
            fi
          '';
          on-click = "true"; # NOOP; Triggers exec when clicked
          exec-on-event = true;
          interval = 600;
          return-type = "json";
          format = "{}";
          tooltip = false;
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

        #custom-vpn.connected {
          color: #00FF00;
        }

        #custom-vpn.disconnected {
          color: #FF0000;
        }
      '';
    };
  };
}


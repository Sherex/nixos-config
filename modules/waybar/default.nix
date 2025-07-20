{ config, pkgs, lib, home-manager, ... }:

{
  home-manager.users.sherex = { pkgs, ... }: {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
      # https://github.com/Alexays/Waybar/wiki
      settings = [{
        layer = "top";
        position = "top";
        height = 24;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" "custom/wl-gammarelay-temperature" "custom/wl-gammarelay-brightness" "custom/wl-gammarelay-gamma" "pulseaudio" "idle_inhibitor" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "network" "custom/vpn" "cpu" "memory" "temperature" "battery" "tray" "clock" ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch workspace m-1 > /dev/null";
          on-scroll-down = "hyprctl dispatch workspace m+1 > /dev/null";
          format = "{name} <span color='#33ccff'>{windows}</span>";
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
          format-window-separator = "  ";
          window-rewrite-default = "";
          window-rewrite = {
            "title<.*youtube.*>" = "";
            "foot" = "";
            "title<.*(vim|code).*>" = "";
            "steam" = "";
            "class<.*(firefox|librewolf|chrome|qutebrowser).*>" = "";
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
          format-charging = "{capacity}% ({time}) {icon} ";
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
        "custom/wl-gammarelay-temperature" = {
            format = "{} ";
            exec = "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs watch {t}";
            on-scroll-up = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +100";
            on-scroll-down = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -100";
            on-click = "busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 2500";
            on-click-right = "busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 6500";
        };
        "custom/wl-gammarelay-brightness" = {
            format = "{}% ";
            exec = "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs watch {bp}";
            on-scroll-up = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d +0.05";
            on-scroll-down = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.05";
            on-click = "busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d 0.6";
            on-click-right = "busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d 1";
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
            padding-left: 8px;
            padding-right: 8px;
            border-right: 1px solid #00ff00;
        }

        #workspaces button.focused {
            background-color: #005500;
            text-decoration: underline;
        }

        #workspaces button.urgent {
            background-color: #550000;
        }

        #workspaces button.active {
            background-color: #222;
        }

        #workspaces button:hover {
            background: #444;
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

        #custom-wl-gammarelay-temperature {
          color: #FD5E53;
        }

        #custom-wl-gammarelay-brightness {
          color: #DDDDDD;
        }
      '';
    };
  };
}


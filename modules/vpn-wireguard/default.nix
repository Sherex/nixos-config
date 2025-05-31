{ config, pkgs, lib, home-manager, ... }:

{
  networking.wireguard.enable = true;
  networking.wg-quick.interfaces.wg-mullvad = {
    address = [ "10.71.151.118/32" "fc00:bbbb:bbbb:bb01::8:9775/128" ];
    # TODO: Use sops-nix
    privateKeyFile = "/root/wg-mullvad.key";
    dns = [ "194.242.2.2" ];

    postUp = ''
      # Source: https://www.reddit.com/r/Tailscale/comments/14wsf1f/comment/kgp09f2

      # Set up a new tailscale - wireguard nftables table and utilize the
      # existing 51820 routing table provided by the wg-quick command by
      # setting the mark on non-tailscale traffic

      echo Enabling Tailscale chain
      ${pkgs.nftables}/bin/nft -f - <<EOF
      # make sure the tables and rules are empty
      add table ip tailscale-wg;
      add chain ip tailscale-wg preraw;
      flush chain ip tailscale-wg preraw;
      delete chain ip tailscale-wg preraw;

      table ip tailscale-wg {
        chain preraw {
          type filter hook prerouting priority raw; policy accept;
          iifname "tailscale0" ip daddr != 100.70.0.0/16 mark set 51820;
        }
      }

      EOF

      wg set "wg-mullvad" fwmark off

      # I only have ipv4 set up
      ip -4 rule del not fwmark 51820 table 51820
      # ip -6 rule del not fwmark 51820 table 51820

      ip -4 rule add fwmark 51820 table 51820
      # ip -6 rule add fwmark 51820 table 51820
    '';

    preDown = ''
      echo Disabling Tailscale chain
      ${pkgs.nftables}/bin/nft -f - <<EOF
      # Make sure all tables and rules created are deleted
      add table ip tailscale-wg;

      add chain ip tailscale-wg preraw;
      flush chain ip tailscale-wg preraw;
      delete chain ip tailscale-wg preraw;

      delete table ip tailscale-wg;
      EOF
    '';

    peers = [
      {
        publicKey = "ScQu/AqslSPwpXMIEyimrYZWTIdJJXLLeXrijWOF0SE=";
        allowedIPs = [ "0.0.0.0/0" "::0/0" ];
        endpoint = "178.255.149.140:51820";
      }
      # {
      #   publicKey = "IhhpKphSFWpwja1P4HBctZ367G3Q53EgdeFGZro29Tc=";
      #   allowedIPs = [ "0.0.0.0/0" "::0/0" ];
      #   endpoint = "176.125.235.72:51820";
      # }
    ];
  };

}


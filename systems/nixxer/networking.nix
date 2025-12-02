{ config, pkgs, ... }:

{
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    netdevs = {
      "30-br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
          MACAddress = "none";
        };
      };
    };
    networks = {
      "30-enp3s0f0" = { # Gateway
        name = "enp3s0f0";
        bridge = ["br0"];
      };
      "30-enp3s0f1" = { # Router
        name = "enp3s0f1";
        bridge = ["br0"];
      };
      "30-br0" = {
        name = "br0";
        DHCP = "yes";
        dhcpV4Config = {
          UseDomains = true;
        };
        ipv6AcceptRAConfig = {
          UseDNS = false;
        };
        dhcpV6Config = {
          UseDNS = false;
        };
      };
    };
    links = {
      "30-br0" = {
        matchConfig = {
          OriginalName = "br0";
        };
        linkConfig = {
          MACAddressPolicy = "none";
        };
      };
    };
  };
}

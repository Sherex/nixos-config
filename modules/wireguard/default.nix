{ config, pkgs, lib, ... }:

let
  s = config.sops.secrets;
  getSecret = (secret: builtins.readFile s."${secret}".path);
in {
  sops.secrets = {
    "user/wireguard/main-net/private-key" = {};
  };

  networking.firewall = {
    allowedUDPPorts = [ 51872 ];
  };


  #let
  #  wireguardSecrets = lib.modules.importJSON "./secrets/wireguard.json"
  #in
  # https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=alpha_asc&type=packages&query=networking.wg-quick
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      ips = [ "10.10.0.20/24" ];

      privateKeyFile = s."user/wireguard/main-net/private-key".path;

      peers = [
        {
          endpoint = getSecret "wireguard/main-net/peers/vps/endpoint";
          publicKey = getSecret "wireguard/main-net/peers/vps/public-key";
          allowedIPs = [ "10.10.0.0/24" "10.1.0.0/24" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}


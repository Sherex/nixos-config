{ config, pkgs, lib, ... }:

let
  host = {
    tailscale_ip = "100.70.0.2";
  };
  coredns = pkgs.coredns.override {
    externalPlugins = lib.singleton {
      name = "rqlite";
      repo = "github.com/Sherex/coredns_rqlite";
      version = "c55610db3e1432e16d6f10012e9bcb9080e06f55";
      position.before = "forward";
    };
  };
in
{
  services.coredns = {
    enable = true;
    package = coredns;
    config = ''
      .:5356 {
        errors
        log
        cache 600

        rqlite {
          dsn http://${host.tailscale_ip}:4001
        }
      }
    '';
  };

}




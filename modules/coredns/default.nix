{ config, pkgs, lib, ... }:

let
  cfg = config.modules.coredns;
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
  options.modules.coredns = {
    enable = lib.mkEnableOption "coredns";
    dnsListenAddress = lib.mkOption {
      type = lib.types.str;
      example = "127.0.0.1:53";
      default = ".:5356";
      description = ''
        The listen address of the CoreDNS server connected to the Rqlite DB.
      '';
    };
    rqliteAddress = lib.mkOption {
      type = lib.types.str;
      example = "http://127.0.0.1:4001";
      description = ''
        The listen address of the Rqlite instance running on this host.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.coredns = {
      enable = true;
      package = coredns;
      config = ''
        ${cfg.dnsListenAddress} {
          errors
          log
          cache 600

          # rqlite {
          #   dsn ${cfg.rqliteAddress}
          # }
        }
      '';
    };
  };
}




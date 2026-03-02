{ inputs, config, pkgs, lib,  ... }:

{
  services = {
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      resolver.addresses = [ "127.0.0.53" ];
    };
  };
  users.users.nginx.extraGroups = ["acme"]; # Give Nginx rights to access certs

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ingar+acme@i-h.no";
      dnsProvider = "luadns";
      dnsResolver = "1.1.1.1:53";
      # TODO: Use SOPS-nix for acme secrets
      environmentFile = "/persistent/safe/acme-secrets.env";
      webroot = null; # Use DNS challenge
    };
    certs."i-h.no" = {
      extraDomainNames = ["*.i-h.no"];
    };
    certs."s3.i-h.no" = {
      extraDomainNames = [ "*.s3.i-h.no" "web.i-h.no" "*.web.i-h.no"];
    };
  };

  environment.persistence."/persistent/safe" = {
    directories = [
      "/var/lib/acme"
    ];
  };
}


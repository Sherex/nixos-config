{ config, pkgs, lib, home-manager, ... }:

{
  users.users.sherex.extraGroups = [ "libvirtd" ];

  home-manager.users.sherex = { pkgs, ... }: {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
    home.packages = with pkgs; [
      virt-viewer
    ];
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
    extraConfig = ''
      unix_sock_group = "libvirtd";
      unix_sock_rw_perms = "0770";
    '';
  };

  programs.virt-manager.enable = true;

  environment.persistence."/persistent/safe" = {
    directories = [
      "/var/lib/libvirt"
      "/var/lib/swtpm-localca"
    ];
  };
}


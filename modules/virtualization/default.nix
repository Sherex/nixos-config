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
    onBoot = "ignore";
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
      swtpm.enable = true;
      runAsRoot = false;
    };
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

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };
}


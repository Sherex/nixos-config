let
  subvolumes_path = "/subvolumes";
in {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.0025385871b0d9d9";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "boot";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              name = "nixos";
              size = "100%";
              content = {
                type = "btrfs";
                #extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "${subvolumes_path}/tmp-blank" = {};
                  "${subvolumes_path}/tmp" = {
                    mountpoint = "/";
                    mountOptions = [ "noatime" ];
                  };
                  "${subvolumes_path}/safe" = {
                    mountpoint = "/persistent/safe";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                  "${subvolumes_path}/unsafe" = {
                    mountpoint = "/persistent/unsafe";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                  "${subvolumes_path}/unsafe/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                  # "/swap" = {
                  #   mountpoint = "/.swapvol";
                  #   swap = {
                  #     swapfile.size = "20M";
                  #     swapfile2.size = "20M";
                  #     swapfile2.path = "rel-path";
                  #   };
                  # };
                };

                mountpoint = "/partition-root";
              };
            };
          };
        };
      };
      storage = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD1003FZEX-00K3CA0_WD-WCC6Y3XFH6PL";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              name = "storage";
              size = "100%";
              content = {
                type = "btrfs";
                #extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "${subvolumes_path}/storage" = {
                    mountpoint = "/persistent/unsafe/storage";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                  "${subvolumes_path}/media" = {
                    mountpoint = "/srv/containers/jellyfin/container-data/media";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                };

                mountpoint = "/partition-storage";
              };
            };
          };
        };
      };
    };
  };
}

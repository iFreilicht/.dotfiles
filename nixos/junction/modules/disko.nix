let
  mnt = import ../mountpoints.nix;

  # ON REINSTALL: Create this file manually and store the passphrase in it
  bigz_key = "/etc/zfs/bigz.key";
in
{
  systemd.tmpfiles.rules = [
    "z ${bigz_key} 0600 root root" # Don't create the keyfile, but ensure it has the correct permissions
  ];
  # After making changes here, apply them like so:
  # $ vim $(disko --mode format --dry-run disko.nix)
  # Review this script first! This feature is new and may cause data loss! Once done, you can run:
  # disko --mode format --dry-run disko.nix
  disko.devices = {
    zpool = {
      bigz = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          # LZ4 is the default compression algorithm since 2020, which is an improvement over no compression for any workload
          compression = "on";
          encryption = "aes-256-gcm";
          keylocation = "file:///etc/zfs/bigz.key";
          keyformat = "passphrase"; # Passphrase can be up to 512 bytes long, raw and hex keys are limited to 32 bytes
        };
        postCreateHook = "zfs list -t snapshot -o name bigz | grep -q '^bigz@blank$' || zfs snapshot bigz@blank";

        datasets = {
          "forgejo" = {
            type = "zfs_fs";
            options = {
              mountpoint = mnt.forgejo;
              "com.sun:auto-snapshot" = "true";
            };
          };
          "ftp" = {
            type = "zfs_fs";
            options = {
              mountpoint = mnt.ftp;
            };
          };
          "home-assistant" = {
            type = "zfs_fs";
            options = {
              mountpoint = mnt.home-assistant;
              "com.sun:auto-snapshot" = "true";
            };
          };
          "jellyfin" = {
            type = "zfs_fs";
            options = {
              mountpoint = mnt.jellyfin;
              "com.sun:auto-snapshot" = "true";
            };
          };
          "nextcloud" = {
            type = "zfs_fs";
            # Use options.mountpoint instead of mountpoint to avoid systemd mount units, which interfere with zfs-import*.service
            # See also https://github.com/nix-community/disko/issues/581#issuecomment-2260602290
            options = {
              mountpoint = mnt.nextcloud;
              "com.sun:auto-snapshot" = "true";
            };
          };
          "mysql" = {
            type = "zfs_fs";
            options = {
              mountpoint = mnt.mysql;
              "com.sun:auto-snapshot" = "true";
            };
          };
          "samba" = {
            type = "zfs_fs";
            options = {
              mountpoint = mnt.samba;
            };
          };
          "transmission" = {
            type = "zfs_fs";
            options = {
              mountpoint = mnt.transmission;
            };
          };
        };
      };
    };
    disk = {
      # ZFS storage pool, disk 1
      bigz_1 = {
        device = "/dev/disk/by-id/ata-ST16000NM001G-2KK103_ZL28WEM8";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            bigz_1 = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "bigz";
              };
            };
          };
        };
      };
      # ZFS storage pool, disk 2
      bigz_2 = {
        device = "/dev/disk/by-id/ata-ST16000NM001G-2KK103_ZL28WEM8";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            bigz_2 = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "bigz";
              };
            };
          };
        };
      };
      nix_store = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_250GB_S3YJNB0K214790E";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            nix_store = {
              end = "-8G"; # Half of installed RAM capacity for swap
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [
                  "-L"
                  "nix_store"
                ];
                mountpoint = "/nix/store";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };
      scratch_drive = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_250GB_S21PNSAG237083K";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            scratch = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [
                  "-L"
                  "scratch"
                ];
                mountpoint = mnt.scratch;
              };
            };
          };
        };
      };
      # Boot USB Stick
      boot_drive = {
        device = "/dev/disk/by-id/usb-USB_SanDisk_3.2Gen1_0401f4a3f049a993ca43cb8610662699a3109583e0a0b515303f5b4a9d1ceb48c51a00000000000000000000a8cb2db1ff11101891558107592b5dcb-0:0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "4G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [
                  "-n"
                  "BOOT"
                ];
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
                mountpoint = "/boot";
              };
            };
            nixos = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [
                  "-L"
                  "nixos"
                ];
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}

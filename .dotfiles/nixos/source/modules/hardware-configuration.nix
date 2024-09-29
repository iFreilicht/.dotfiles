# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ca548f68-4e51-4364-b366-690ecc27590f";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/2740-1628";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/home" = {
      device = "/dev/mapper/crypt-home";
      fsType = "btrfs";
    };

    "/mnt/g" = {
      device = "/dev/disk/by-uuid/7CA41E5EA41E1B6A";
      fsType = "ntfs";
      options = [
        "uid=1000"
        "gid=100" # group users on NixOS
      ];
    };

    "/mnt/s" = {
      device = "/dev/disk/by-uuid/9A48E8C248E89E6F";
      fsType = "ntfs";
      options = [
        "uid=1000"
        "gid=100" # group users on NixOS
      ];
    };
  };

  boot.initrd.luks.devices."crypt-home".device = "/dev/disk/by-uuid/879299db-4147-4fac-9f34-5e8e92073efc";

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp5s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}

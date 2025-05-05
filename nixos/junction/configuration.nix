# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{
  pkgs,
  net,
  wireguard,
  ...
}:
{
  imports = [
    ../common.nix
    ../modules/be-remote-builder.nix
    ../modules/ensure-root-ssh-key.nix
    ../modules/machine-type.nix
    ../modules/use-remote-builders.nix
    ../modules/user-felix.nix
    ./modules/disko.nix # Drive configuration
    ./modules/hardware-configuration.nix # Include the results of the hardware scan.
    wireguard.junction
    # Modules for services
    ./modules/audiobookshelf.nix
    ./modules/borg.nix
    ./modules/containerized-apps.nix
    ./modules/dns.nix
    ./modules/ftp.nix
    ./modules/git.nix
    ./modules/home-assistant.nix
    ./modules/jellyfin.nix
    ./modules/nextcloud.nix
    ./modules/nginx.nix
    ./modules/ntp.nix
    # ./modules/mullvad.nix
    ./modules/pihole.nix
    ./modules/samba.nix
    # ./modules/transmission.nix
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "delayacct" # Enable process accounting to allow tracking I/O load with btop or iotop
    ];

    # Use the latest LTS kernel to guarantee support for ZFS
    kernelPackages = pkgs.linuxPackages;
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    zfs.extraPools = [ "bigz" ];
  };

  networking.hostId = "feb10dc9"; # Helps prevent accidental imports of zpools
  networking.hostName = "junction";
  uhl.machineType = "server";

  # Use nftables instead of legacy iptables. It can be configured declaratively as well.
  networking.nftables.enable = true;

  programs.nix-ld.enable = true;

  # Scrub zpool once every month
  services.zfs.autoScrub.enable = true;
  # Snapshot every 15 minutes, automatically discard old ones
  services.zfs.autoSnapshot = {
    # ON REINSTALL: Set `com.sun:auto-snapshot=true` on all datasets that should be snapshotted automatically!
    enable = true;
    flags = "-k -p --utc"; # UTC is recommended as local time can cause conflicts due to DST
  };

  # Enable power saving features
  powerManagement.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  felix.authorizedKeys = [
    net.horse.felix.publicKey
    net.source.felix.publicKey
  ];

  # Allow my own user to use sudo without a password. This works around an issue with remote nixos-rebuild switch,
  # see https://discourse.nixos.org/t/remote-nixos-rebuild-works-with-build-but-not-with-switch/34741/7?u=ifreilicht
  security.sudo.wheelNeedsPassword = false;

  nix.settings.cores = 6; # Use less than all available cores when building to avoid overloading the system
  uhl.beRemoteBuilder.authorizedKeys = [
    net.horse.root.publicKey
    net.gateway.root.publicKey
  ];
  uhl.useRemoteBuilders = [
    "source"
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

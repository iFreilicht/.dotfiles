# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [
      ../common.nix
      ./hardware-configuration.nix # Include the results of the hardware scan.
      (import ../wireguard.nix { inherit (pkgs) lib; }).junction
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest kernel compatible with OpenZFS
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank" ];

  networking.hostId = "feb10dc9"; # Helps prevent accidental imports of zpools
  networking.hostName = "junction";

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8 * 1024; # Half of installed RAM
  }];

  # Scrub zpool once every week
  services.zfs.autoScrub.enable = true;

  # Enable power saving features
  powerManagement.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.felix = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9OOXhRhYgpaFLwbkfcQsSYYUTr+qsbf0WIHcUm2fFQ felix@horse"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0TI3HN6e00Bv29ui7BUCYSa4FBjcWBs4fE5R1ODc9+ felix@source"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  # Allow my own user to use sudo without a password. This works around an issue with remote nixos-rebuild switch,
  # see https://discourse.nixos.org/t/remote-nixos-rebuild-works-with-build-but-not-with-switch/34741/7?u=ifreilicht
  security.sudo.wheelNeedsPassword = false;

  # User account to run remote builds
  users.users.remote-build = {
    isSystemUser = true;
    hashedPassword = ""; # Only allow login via ssh
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMj4suEfNQKtFyYVlO3bgawvKuM/FWYtgu6BPMe5R8ia root@horse"
    ];
    shell = pkgs.bash;
    group = "remote-build";
  };
  users.groups.remote-build = { };

  # Ensure both users can actually build derivations
  nix.settings.trusted-users = [
    "felix"
    "remote-build"
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # User-facing services
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_106;
    dataDir = "/mnt/mysql";
    ensureDatabases = [
      "nextcloud"
    ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions = {
          "nextcloud.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  environment.etc."nextcloud-admin-pass".text = "default-admin-pass-plz-change";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "cloud.uhl.cx";
    home = "/mnt/nextcloud";
    configureRedis = true;
    config = {
      dbtype = "mysql";
      adminpassFile = "/etc/nextcloud-admin-pass";
      extraTrustedDomains = [
        # Required for local access
        "junction"
        "192.168.178.48"
      ];
    };
  };



  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}


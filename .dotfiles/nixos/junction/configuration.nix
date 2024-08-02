# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:
let
  mnt = import ./mountpoints.nix;
  net = import ../network.nix;
in
{
  imports =
    [
      ../common.nix
      ./hardware-configuration.nix # Include the results of the hardware scan.
      ./disko.nix # Drive configuration
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
      net.horse.ssh.publicKey
      net.source.ssh.publicKey
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
  # This is a workaround, I'm trying to get it upstreamed in https://github.com/NixOS/nixpkgs/pull/331296
  systemd.tmpfiles.rules = [
    "d ${mnt.mysql} 0750 mysql mysql - -"
  ];
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_106;
    dataDir = mnt.mysql;
  };

  # ON REINSTALL: Change the admin password to a new random one
  environment.etc."nextcloud-admin-pass".text = "default-admin-pass-plz-change";
  services.nginx.virtualHosts.${net.nextcloud.domain}.listen = [
    { addr = "0.0.0.0"; port = net.nextcloud.port; }
  ];
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = net.nextcloud.domain;
    home = mnt.nextcloud;
    configureRedis = true;
    database.createLocally = true;
    config = {
      dbtype = "mysql";
      adminpassFile = "/etc/nextcloud-admin-pass";
    };
    settings = {
      trusted_proxies = [ net.gateway.wireguard.ip ];
      trusted_domains = [
        # Required for local access
        "junction"
        "192.168.178.48"
        # Allow access via wireguard
        net.junction.wireguard.ip
      ];
      overwriteprotocol = "https";
      default_phone_region = "DE";
    };
  };

  virtualisation.oci-containers.containers = {
    "snapdrop" = {
      image = "linuxserver/snapdrop";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "linuxserver/snapdrop";
        finalImageTag = "version-debd13a0";
        imageDigest = "sha256:79f2c93ab4cdeb2e8c520d0a43a4d5ec9cc366eec189df65ea5866bfcc0e8e5c";
        sha256 = "sha256-8OLtduEkPBwG248iAQ7crj+QkG8NCksX4LYalH/bMYA=";
      };
      ports = [
        "${toString net.snapdrop.port}:80"
      ];
    };

    "kritzeln" = {
      image = "biosmarcel/scribble.rs";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "biosmarcel/scribble.rs";
        finalImageTag = "v0.8.8";
        imageDigest = "sha256:28cccbbd4110117c1149a2cce6a0458ec8b381b64e18af2131ea224c8f5c2d82";
        sha256 = "sha256-NjR6fKh7uONWZ3leQd6dYGQhLtFXWjcFd+mhITKzVXg=";
      };
      ports = [
        "${toString net.kritzeln.port}:8080"
      ];
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    net.nextcloud.port
    net.snapdrop.port
    net.kritzeln.port
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}


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

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "borg/passphrase" = {
        reloadUnits = [ "borgmatic.service" ];
      };
    };
  };

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

  programs.ssh.knownHosts = with net.borgbase.repos; {
    ${files.host}.publicKey = net.borgbase.publicKey;
    ${databases.host}.publicKey = net.borgbase.publicKey;
  };

  # The root user needs an ssh key for borgmatic to be able to connect to the backup repos
  # ON REINSTALL: Run `sudo cat /root/.ssh/id_ed25519.pub` and add the output to the allowed keys in borgbase
  systemd.services.ensure-root-ssh-key = {
    enable = true;
    description = "Ensure that the root user has an ssh key. Generate one if necessary.";
    script = ''
      mkdir -p /root/.ssh
      chmod 700 /root/.ssh
      chown root:root /root/.ssh
      if [ ! -f /root/.ssh/id_ed25519 ]; then
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ""
      fi
    '';
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };


  # Backups
  services.borgmatic =
    let
      commonSettings = {
        compression = "lz4";
        archive_name_format = "backup-{now}";
        keep_hourly = 3;
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 6;
        keep_yearly = 10;

        # These options are used when `borgmatic check` is run
        check_last = 3;
      };
    in
    {
      enable = true;

      # ON REINSTALL: Run `sudo nix run nixpkgs#borgmatic -- init -e repokey-blake2` to initialize the repos,
      # or, when restoring from backups, research how to setup the repos from an existing remote repo
      configurations = {
        files = commonSettings // {
          source_directories = [
            "/mnt/nextcloud/"
          ];
          exclude_patterns = [
            "nextcloud.log" # Changes often, not important for nextcloud to run
          ];
          repositories = [
            { inherit (net.borgbase.repos.files) path label; }
          ];
        };

        databases = commonSettings // {
          source_directories = [ ];
          repositories = [
            { inherit (net.borgbase.repos.databases) path label; }
          ];

          mysql_databases = [
            {
              name = "nextcloud";
            }
          ];
        };
      };
    };
  systemd.services.borgmatic = {
    path = [
      # borgmatic requires mysqldump to be in the path to be able to backup MySQL databases
      pkgs.mariadb_106
    ];
    environment = {
      BORG_PASSCOMMAND = "cat ${config.sops.secrets."borg/passphrase".path}";
    };
  };
  systemd.timers.borgmatic.timerConfig = {
    # Run the backup every 15 minutes starting 5 minutes past the hour
    OnCalendar = "*-*-* *:5/15";
    RandomizedDelaySec = "0"; # Default is 3h, which makes no sense for a 15min interval
  };


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
    phpOptions."opcache.interned_strings_buffer" = "23";
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


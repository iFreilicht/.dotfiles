{ pkgs, net, mnt, ... }:

{
  # This is a workaround, I'm trying to get it upstreamed in https://github.com/NixOS/nixpkgs/pull/331296
  systemd.tmpfiles.rules = [
    "d ${mnt.mysql} 0750 mysql mysql - -"
  ];
  # DB for nextcloud
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_106; # Older nextcloud versions had issues with up-to-date mariadb
    dataDir = mnt.mysql;
  };

  # Initial pw file, required for first install
  # ON REINSTALL: Change the admin password to a new random one
  environment.etc."nextcloud-admin-pass".text = "default-admin-pass-plz-change";

  # Set port nextcloud is reachable on
  services.nginx.virtualHosts.${net.nextcloud.domain} = {
    listen = [
      # Port to listen on for traffic from the wireguard network
      { addr = net.junction.wireguard.ip; port = net.nextcloud.port; }
      # Default addresses to listen on for local access
      { addr = "0.0.0.0"; port = 443; ssl = true; }
      { addr = "[::0]"; port = 443; ssl = true; }
    ];
    useACMEHost = net.domain;
    addSSL = true;
    # gateway proxies traffic to an HTTP port, so we can't use forceSSL.
    # Instead, we forward the default port to the SSL port manually.
    extraConfig = ''
      }
      server {
        listen 0.0.0.0:80 ;
        listen [::0]:80 ;
        server_name ${net.nextcloud.domain} ;
        location / {
          return 301 https://$host$request_uri;
        }
    '';
  };

  # Ensure nextcloud will be accessed directly by clients in the same network
  uhl.dns.entries.${net.nextcloud.subDomain} = net.junction.home.ip;

  # Ensure our certificate also covers the nextcloud domain
  security.acme.certs.${net.domain} = {
    extraDomainNames = [ net.nextcloud.domain ];
  };

  # Nextcloud itself
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
      log_type = "file"; # When using file logging, logs are displayed in the admin panel
    };
    phpOptions."opcache.interned_strings_buffer" = "23";
  };

  # Peer dependencies of store-installed apps
  environment.systemPackages = with pkgs; [
    # Required for recognize. I checked `/mnt/nextcloud/store-apps/recognize/bin/x64.tar.gz`
    # and it contains nodejs 14.18.2, but 18 is the oldest that's not EOL
    nodejs_18
  ];

  # Backups
  services.borgmatic.configurations = {
    files = {
      source_directories = [ mnt.nextcloud ];
      exclude_patterns = [
        "nextcloud.log" # Changes often, not important for nextcloud to run
      ];
    };
    databases = {
      mysql_databases = [{ name = "nextcloud"; }];
    };
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [
    net.nextcloud.port
  ];
}

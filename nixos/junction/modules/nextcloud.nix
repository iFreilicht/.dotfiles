{
  pkgs,
  lib,
  net,
  mnt,
  ...
}:

{
  # This is a workaround, I'm trying to get it upstreamed in https://github.com/NixOS/nixpkgs/pull/331296
  systemd.tmpfiles.rules = [ "d ${mnt.mysql} 0750 mysql mysql - -" ];
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
      {
        addr = net.junction.wireguard.ip;
        port = net.nextcloud.port;
      }
      # Default addresses to listen on for local access
      {
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      }
      {
        addr = "[::0]";
        port = 443;
        ssl = true;
      }
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
    package = pkgs.nextcloud31;
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
      default_language = "de";
      default_locale = "de_DE";
      log_type = "file"; # When using file logging, logs are displayed in the admin panel
      loglevel = 1;
      maintenance_window_start = 1; # Run maintenance tasks from 1-5am UTC (3-7am local time in summer, 2-6am in winter)
      enabledPreviewProviders = [
        # Default providers
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        # Additional providers
        "OC\\Preview\\HEIC"
        "OC\\Preview\\Movie"
        "OC\\Preview\\PDF"
        "OC\\Preview\\SVG"
      ];
    };
    phpOptions = {
      upload_max_filesize = lib.mkForce "4G";
      memory_limit = lib.mkForce "8G";
      "opcache.interned_strings_buffer" = "23";
    };
    maxUploadSize = lib.mkForce net.nextcloud.nginx_max_body_size;
  };

  # Peer dependencies of store-installed apps
  environment.systemPackages = with pkgs; [
    # Required for recognize. Check the "Node.js" box on https://cloud.uhl.cx/settings/admin/recognize
    # to see which version is currently required
    nodejs_20
  ];

  # Backups
  services.borgmatic.configurations = {
    files = {
      source_directories = [ mnt.nextcloud ];
      exclude_patterns = [
        "nextcloud.log" # Changes often, not important for nextcloud to run
        "audit.log" # Provided by the Auditing / Logging app
      ];
    };
    databases = {
      mysql_databases = [ { name = "nextcloud"; } ];
    };
  };

  # Allow direct HTTP access to nextcloud from wireguard only
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ net.nextcloud.port ];
}

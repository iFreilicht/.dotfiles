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
  services.nginx.virtualHosts.${net.nextcloud.domain}.listen = [
    { addr = "0.0.0.0"; port = net.nextcloud.port; }
  ];

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
    };
    phpOptions."opcache.interned_strings_buffer" = "23";
  };

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

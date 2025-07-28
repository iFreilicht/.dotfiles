{
  net,
  mnt,
  lib,
  ...
}:
let
  dataDir = "${mnt.jellyfin}/data";
  movieDir = "${mnt.jellyfin}/Movies";
  showsDir = "${mnt.jellyfin}/Shows";
  musicDir = "${mnt.jellyfin}/Music";
in
{
  services.jellyfin = {
    enable = true;
    dataDir = dataDir;
    # Don't store logs in dataDir, as that is backed up remotely
    logDir = "/var/log/jellyfin";
  };

  # Set up folder structure and permissions
  systemd.tmpfiles.rules =
    [
      "d ${dataDir} 0750 jellyfin jellyfin - -" # Only jellyfin should write to the data dir
    ]
    # Allow jellyfin and regular users to add/access media
    # Also make media world-readable to allow access via bind mounts in SMB
    ++ lib.map (dir: "d ${dir} 0775 jellyfin users - -") [
      movieDir
      showsDir
      musicDir
    ];

  # Proxy Jellyfin through Nginx for SSL termination
  services.nginx = {
    virtualHosts.${net.jellyfin.domain} = {
      forceSSL = true;
      useACMEHost = net.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString net.jellyfin.port}/";
        proxyWebsockets = true;
      };
    };
  };

  # Discovery port to make setup easier
  networking.firewall.allowedUDPPorts = [ 7359 ];

  # Ensure home-assistant can be accessed locally
  uhl.dns.entries.${net.jellyfin.subDomain} = net.junction.home.ip;

  # Ensure our certificate also covers the home-assistant domain
  security.acme.certs.${net.domain} = {
    extraDomainNames = [ net.jellyfin.domain ];
  };

  # Backups
  services.borgmatic.configurations.files = {
    source_directories = [
      # Only back up metadata and configuration, media is too big for remote backups
      dataDir
    ];
  };
}

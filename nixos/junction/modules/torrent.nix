{
  mnt,
  net,
  ...
}:
let
  webUiPort = toString net.torrent.port;
  torrentingPort = toString net.torrent.torrentingPort;
  configPath = "${mnt.transmission}/config";
  downloadsPath = "${mnt.transmission}/downloads";
in
{
  # Ensure qbittorrent will be accessed directly by clients in the home network
  uhl.dns.entries.${net.torrent.subDomain} = net.junction.home.ip;

  # Ensure our certificate also covers the torrent domain
  security.acme.certs.${net.domain} = {
    extraDomainNames = [ net.torrent.domain ];
  };

  # Serve Web-UI via nginx
  services.nginx.virtualHosts.${net.torrent.domain} = {
    useACMEHost = net.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${webUiPort}";
      proxyWebsockets = true;
    };
  };

  # Set up working directories
  systemd.tmpfiles.rules = [
    "d ${configPath} 0700 root podman -"
    "d ${downloadsPath} 0775 root podman -"
  ];

  virtualisation.oci-containers.containers.torrent = {
    image = "docker.io/linuxserver/qbittorrent";
    pull = "newer"; # Automatically update on restarts
    ports = [
      "127.0.0.1:${webUiPort}:8080"
      "${net.junction.wireguard.ip}:${webUiPort}:8080"
      "127.0.0.1:${torrentingPort}:${torrentingPort}"
      "127.0.0.1:${torrentingPort}:${torrentingPort}/udp"
    ];
    environment = {
      TORRENTING_PORT = torrentingPort;
    };
    volumes = [
      "${configPath}:/config"
      "${downloadsPath}:/downloads"
    ];
  };
}

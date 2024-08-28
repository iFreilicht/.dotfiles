{ net, ... }:
let
  etc-pihole = "/etc/pihole-docker/pihole";
  etc-dnsmasq = "/etc/pihole-docker/dnsmasq.d";
in
{

  # Host the apps at regular HTTP ports, but only accessible to localhost or via wireguard
  virtualisation.oci-containers.containers = {
    "pihole" = {
      image = "pihole/pihole";
      ports = [
        # Allow web interface only from localhost so we can enforce SSL with nginx
        "127.0.0.1:${toString net.pihole.port}:80/tcp"
        # Allow DNS queries from any IP
        "${toString net.pihole.dnsPort}:53/tcp"
        "${toString net.pihole.dnsPort}:53/udp"
      ];
      volumes = [
        "${etc-pihole}:/etc/pihole"
        "${etc-dnsmasq}:/etc/dnsmasq.d"
      ];
      environment = {
        TZ = "Europe/Berlin";
        VIRTUAL_HOST = net.pihole.domain;
        PROXY_LOCATION = net.pihole.domain;
        FTLCONF_LOCAL_IPV4 = "127.0.0.1"; # Not sure what this is for, but it's in the example
      };
      extraOptions = [
        # Fall back on Cloudflare and Google DNS servers
        "--dns=1.1.1.1"
        "--dns=1.0.0.1"
        "--dns=8.8.8.8"
        "--dns=8.8.4.4"
      ];
    };
  };

  # For now, only create the directories for pihole to have persistent storage
  # We might want to set up config files there as well in the future
  systemd.tmpfiles.rules = [
    "d ${etc-pihole} 0775 root podman -"
    "d ${etc-dnsmasq} 0775 root podman -"
  ];

  # Ensure the web interface is accessible locally via HTTPS only
  security.acme.certs.${net.domain}.extraDomainNames = [ net.pihole.domain ];
  services.nginx.virtualHosts = {
    ${net.pihole.domain} = {
      useACMEHost = net.domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString net.pihole.port}";
      };
    };
  };
  uhl.dns.entries.${net.pihole.subDomain} = net.junction.home.ip;
}

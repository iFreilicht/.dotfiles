{ mnt, net, ... }:
{
  # Ensure transmission will be accessed directly by clients in the home network
  uhl.dns.entries.${net.transmission.subDomain} = net.junction.home.ip;

  # Ensure our certificate also covers the transmission domain
  security.acme.certs.${net.domain} = {
    extraDomainNames = [ net.transmission.domain ];
  };

  # Proxy Home Assistant through Nginx for SSL termination
  services.nginx = {
    virtualHosts.${net.transmission.domain} = {
      forceSSL = true;
      useACMEHost = net.domain;
      locations."/" = {
        proxyPass = "http://localhost:${toString net.transmission.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_intercept_errors on;
        '';
      };
    };
  };

  # Configure transmission daemon
  services.transmission = {
    enable = true;
    home = mnt.transmission;
    openFirewall = true;
    openRPCPort = true;
    settings = {
      # TODO: Add password auth before allowing access without VPN
      rpc-port = net.transmission.port;
      rpc-bind-address = "0.0.0.0";
      rpc-host-whitelist = net.transmission.domain;
      rpc-whitelist = "127.0.0.1"; # Only allow connection through nginx
    };
  };
}

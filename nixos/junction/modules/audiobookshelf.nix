{ net, ... }:
{
  services.audiobookshelf = {
    enable = true;
    port = net.audiobookshelf.port;
  };

  # Proxy audiobookshelf through Nginx for SSL termination
  services.nginx = {
    virtualHosts.${net.audiobookshelf.domain} = {
      forceSSL = true;
      useACMEHost = net.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString net.audiobookshelf.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_redirect http:// $scheme://;
        '';
      };
    };
  };

  # Ensure audiobookshelf can be accessed locally
  uhl.dns.entries.${net.audiobookshelf.subDomain} = net.junction.home.ip;

  # Ensure our certificate also covers the audiobookshelf domain
  security.acme.certs.${net.domain} = {
    extraDomainNames = [ net.audiobookshelf.domain ];
  };

}

{ net, ... }:
let
  port = 33312;
  subDomain = "code-server";
  domain = "${subDomain}.uhl.cx";
in
{
  # Enable code-server (temporary for testing)
  services.code-server = {
    enable = true;
    auth = "none";
    port = port;
  };

  uhl.dns.entries.${subDomain} = net.junction.home.ip;

  security.acme.certs.${net.domain} = {
    extraDomainNames = [ domain ];
  };

  services.nginx.virtualHosts = {
    ${domain} = {
      useACMEHost = net.domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}/";
        proxyWebsockets = true;
      };
    };
  };
}

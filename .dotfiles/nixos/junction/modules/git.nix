{
  config,
  mnt,
  net,
  ...
}:
{
  services.forgejo = {
    enable = true;
    stateDir = mnt.forgejo;

    settings = {
      server = {
        DOMAIN = net.git.domain;
        ROOT_URL = "https://${net.git.domain}";
        HTTP_PORT = net.git.port;
      };
    };
  };

  # Ensure forgejo will be accessed directly by clients in the same network
  uhl.dns.entries.${net.git.subDomain} = net.junction.home.ip;

  # Ensure our certificate also covers the forgejo domain
  security.acme.certs.${net.domain} = {
    extraDomainNames = [ net.git.domain ];
  };

  # Make nginx serve forgejo via SSL
  services.nginx.virtualHosts = {
    ${net.git.domain} = {
      useACMEHost = net.domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString net.git.port}";
        proxyWebsockets = true;
      };
    };
  };

  # Backups
  services.borgmatic.configurations = {
    files = {
      source_directories = [ mnt.forgejo ];
      exclude_patterns = [
        config.services.forgejo.settings.log.ROOT_PATH
        config.services.forgejo.dump.backupDir
      ];
    };
    databases = {
      mysql_databases = [ { name = "nextcloud"; } ];
    };
  };

  # Allow direct HTTP access to forgejo from wireguard only
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ net.git.port ];
}

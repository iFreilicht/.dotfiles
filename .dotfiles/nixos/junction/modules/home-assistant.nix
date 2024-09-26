{ net, mnt, ... }:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
    ];
    configDir = mnt.home-assistant;
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };

      # Only allow unencrypted access from localhost
      http = {
        server_host = "::1";
        server_port = net.home-assistant.port;
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
    };
  };

  # Proxy Home Assistant through Nginx for SSL termination
  services.nginx = {
    recommendedProxySettings = true;
    virtualHosts.${net.home-assistant.domain} = {
      forceSSL = true;
      useACMEHost = net.domain;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:${toString net.home-assistant.port}/";
        proxyWebsockets = true;
      };
    };
  };

  # Ensure home-assistant can be accessed locally
  uhl.dns.entries.${net.home-assistant.subDomain} = net.junction.home.ip;

  # Ensure our certificate also covers the home-assistant domain
  security.acme.certs.${net.domain} = {
    extraDomainNames = [ net.home-assistant.domain ];
  };

  # Backups
  services.borgmatic.configurations = {
    files = {
      source_directories = [
        # These are the only stateful directories. The other files are DB-related or logs
        "${mnt.home-assistant}/blueprints"
        "${mnt.home-assistant}/custom_components"
        "${mnt.home-assistant}/tts"
      ];
    };
    databases = {
      sqlite_databases = [
        {
          name = "home-assistant";
          path = "${mnt.home-assistant}/home-assistant_v2.db";
        }
      ];
    };
  };
}

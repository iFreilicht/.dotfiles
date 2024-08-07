{ net, ... }: {
  # Automatically renewing SSL certificates
  security.acme = {
    defaults.email = "letsencrypt@mail.felix-uhl.de";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    # Harden nginx as described in https://nixos.wiki/wiki/nginx#Hardened_setup_with_TLS_and_HSTS_preloading
    # Not all settings from the article are compatible with nextcloud.
    appendHttpConfig = ''
      # Add HSTS header with preloading to HTTPS requests.
      # Adding this header to HTTP requests is discouraged
      map $scheme $hsts_header {
          https   "max-age=31536000; includeSubdomains";
      }
      add_header Strict-Transport-Security $hsts_header;

      # Enable CSP
      add_header Content-Security-Policy "object-src 'none'; base-uri 'none';" always;

      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';
    '';

    virtualHosts = {
      ${net.nextcloud.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://${net.junction.wireguard.ip}:${toString net.nextcloud.port}";
      };

      ${net.snapdrop.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${net.junction.wireguard.ip}:${toString net.snapdrop.port}";
          proxyWebsockets = true;
        };
      };

      ${net.kritzeln.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${net.junction.wireguard.ip}:${toString net.kritzeln.port}";
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

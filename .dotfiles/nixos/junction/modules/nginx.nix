{ config, net, ... }:

{
  # Automatically renewing SSL certificates
  security.acme = {
    defaults.email = "letsencrypt@mail.felix-uhl.de";
    acceptTerms = true;

    certs.${net.domain} = {
      # Empty on purpose, each module should set its own subdomain for this
      extraDomainNames = [ ];
      dnsProvider = "hetzner";
      dnsPropagationCheck = true;
      # Use Cloudflare as resolver for DNS propagation check, as my local DNS will not recursively
      # resolve entries like _acme-challenge.cloud.uhl.cx properly, making the check fail
      dnsResolver = "1.1.1.1:53";
      credentialFiles = {
        HETZNER_API_KEY_FILE = config.sops.secrets.hetzner-dns-api-key.path;
      };
    };
  };

  sops.secrets.hetzner-dns-api-key = {
    reloadUnits = [ "acme-cert-${net.domain}.service" ];
  };

  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedBrotliSettings = true;
    recommendedZstdSettings = true;

    # Harden nginx as described in https://nixos.wiki/wiki/nginx#Hardened_setup_with_TLS_and_HSTS_preloading
    appendHttpConfig = ''
      # Add HSTS header with preloading to HTTPS requests.
      # Adding this header to HTTP requests is discouraged
      map $scheme $hsts_header {
          https   "max-age=31536000; includeSubdomains";
      }
    '';
  };

  # Allow nginx to read the challenges from acme
  users.users.nginx.extraGroups = [ "acme" ];

  # Allow HTTP and HTTPS traffic to reach nginx
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}

{
  mnt,
  net,
  ...
}:
{
  services.gitlab = {
    enable = true;
    statePath = "${mnt.gitlab}/state";

    host = net.gitlab.domain;
    port = net.gitlab.port;
    https = true;

    initialRootPasswordFile = "${mnt.gitlab}/initialRootPassword.txt";

    secrets = {
      # Created with hexdump -vn32 -e'16 "%08X" 1 "\n"' /dev/urandom > secretFile.txt
      # Not sure if that's safe. Doesn't matter, only used for testing.
      dbFile = "${mnt.gitlab}/dbFile.txt";
      secretFile = "${mnt.gitlab}/secretFile.txt";
      otpFile = "${mnt.gitlab}/otpFile.txt";
      jwsFile = "${mnt.gitlab}/jwsFile.txt";
    };
  };

  # Ensure gitlab will be accessed directly by clients in the same network
  uhl.dns.entries.${net.gitlab.subDomain} = net.junction.home.ip;

  # Ensure our certificate also covers the gitlab domain
  security.acme.certs.${net.domain} = {
    extraDomainNames = [ net.gitlab.domain ];
  };

  # Make nginx serve gitlab via SSL
  services.nginx.virtualHosts = {
    ${net.gitlab.domain} = {
      useACMEHost = net.domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
        proxyWebsockets = true;
      };
    };
  };

  # Allow direct HTTP access to gitlab from wireguard only
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ net.gitlab.port ];
}

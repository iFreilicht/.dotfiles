{ config, pkgs, lib, net, ... }:

let
  # YYYYMMDDRR where RR can be increased every time a change is made on the same day
  # Only ever increase this number!
  serialn = "2024080901"; # Substitution ${serialn} has same length as string itself
  adminEmail = "admin.${net.domain}"; # Doesn't actually exist, but DNS is private, so doesn't matter
in
{
  options = {
    uhl.dns.entries = lib.mkOption {
      type = with lib.types; attrsOf str;
      example = ''
        {
          cloud = "192.168.178.123";
        }
      '';
      description = ''
        A map of DNS entries to add to the zone file.
        The key is the start of the subDomain, the value is the IP address.
      '';
    };
  };
  config = {
    services.bind = {
      enable = true;
      forwarders = [
        # Forward only to pihole
        "127.0.0.1 port ${toString net.pihole.dnsPort}"
      ];

      # Only allow queries from my private networks
      cacheNetworks = [
        net.home.subnet
        net.gateway.wireguard.subnet
        "127.0.0.0/24"
        "::1/128"
      ];

      # Ensure the local zone is only forwarded to the router, never the other DNS servers.
      # this is necessary so that local hostnames resolve properly
      extraConfig = ''
        zone "${net.home.zone}" IN {
          type forward;
          forward only;
          forwarders { ${net.home.router}; };
        };
      '';


      zones = {
        ${net.domain} = {
          master = true;
          file = pkgs.writeText "${net.domain}.zone"
            (''
              $TTL 86400
              @   IN  SOA ns1.${net.domain}. ${adminEmail}. (
                    ${serialn} ; Serial
                    3600       ; Refresh
                    900        ; Retry
                    1209600    ; Expire
                    86400 )    ; Minimum TTL
                  NS  ns1.${net.domain}.
              ns1 IN A ${net.junction.home.ip}
              @   IN A ${net.junction.home.ip}
            '' +
            (lib.concatStringsSep "\n" (
              lib.mapAttrsToList
                (name: ip: "${name} IN A ${ip}")
                config.uhl.dns.entries
            )) + "\n");
        };
      };
    };

    # DNS uses UDP port 53 normally, but also TCP port 53 for large responses
    networking.firewall = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };
}

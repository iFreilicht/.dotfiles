{ config, pkgs, lib, net, ... }:

let
  # YYYYMMDDRR where RR can be increased every time a change is made on the same day
  # Only ever increase this number!
  serialn = "2024081401"; # Substitution ${serialn} has same length as string itself
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
        # Fall back on Cloudflare and Google DNS servers
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
      ];

      # Only allow queries from wireguard
      cacheNetworks = [
        net.gateway.wireguard.subnet
        "127.0.0.0/24"
        "::1/128"
      ];

      zones = {
        # Redirect access to public services through wireguard
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
              ns1 IN A ${net.gateway.wireguard.ip}
              @   IN A ${net.junction.wireguard.ip}
            '' +
            (lib.concatStringsSep "\n" (
              lib.mapAttrsToList
                (name: ip: "${name} IN A ${ip}")
                config.uhl.dns.entries
            )) + "\n");
        };

        # Set up a TLD zone under which all hosts can be found. This is the search domain for the VPN
        gateway = {
          master = true;
          file = pkgs.writeText "gateway.zone"
            ''
              $TTL 86400
              @   IN  SOA ns1.gateway. ${adminEmail}. (${serialn} 3600 900 1209600 86400)
                  NS  ns1.gateway.
              ns1      IN A ${net.gateway.wireguard.ip}
              @        IN A ${net.gateway.wireguard.ip}
              gateway  IN A ${net.gateway.wireguard.ip}
              junction IN A ${net.junction.wireguard.ip}
            '';
        };

        # Publish a TLD for every host we want to be permanently accessible
        # This is more reliable than using a search domain, which can be overridden by other network adapters
        junction = {
          master = true;
          file = pkgs.writeText "junction.zone"
            ''
              $TTL 86400
              @   IN  SOA ns1.junction. ${adminEmail}. (${serialn} 3600 900 1209600 86400)
                  NS  ns1.junction.
              ns1      IN A ${net.junction.wireguard.ip}
              @        IN A ${net.junction.wireguard.ip}
            '';
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

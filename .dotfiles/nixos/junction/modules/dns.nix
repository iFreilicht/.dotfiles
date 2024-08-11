{ pkgs, net, ... }:

let
  # YYYYMMDDRR where RR can be increased every time a change is made on the same day
  # Only ever increase this number!
  serialn = "2024080901"; # Substitution ${serialn} has same length as string itself
  adminEmail = "admin.${net.domain}"; # Doesn't actually exist, but DNS is private, so doesn't matter
in
{
  services.bind = {
    enable = true;
    forwarders = [
      # The router gets its DNS from the ISP, which might publish some routes other DNS servers don't know about
      net.home.router
      # Fall back on Cloudflare and Google DNS servers
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
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
        file = pkgs.writeText "${net.domain}.zone" ''
          $TTL 86400
          @   IN  SOA ns1.${net.domain}. ${adminEmail}. (
                ${serialn} ; Serial
                3600       ; Refresh
                900        ; Retry
                1209600    ; Expire
                86400 )    ; Minimum TTL
              NS  ns1.${net.domain}.
          ns1      IN A ${net.junction.home.ip}
          @        IN A ${net.junction.home.ip}
          cloud    IN A ${net.junction.home.ip}
          kritzeln IN A ${net.junction.home.ip}
          drop     IN A ${net.junction.home.ip}
        '';
        # TODO: generate records from configuration
      };
    };
  };

  # DNS uses UDP port 53 normally, but also TCP port 53 for large responses
  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}

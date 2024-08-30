{ net, ... }:
{
  services.chrony = {
    enable = true;
    servers = [
      net.gateway.wireguard.ip
      net.gateway.wireguard.initialIP
    ];
    extraConfig = ''
      allow ${net.home.subnet}
    '';
  };

  networking.firewall.allowedUDPPorts = [ 123 ];
}

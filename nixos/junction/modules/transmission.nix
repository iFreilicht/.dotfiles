{ mnt, net, ... }:
{
  services.transmission = {
    enable = true;
    home = mnt.transmission;
    openFirewall = true;
    openRPCPort = true;
    settings = {
      rpc-port = net.transmission.port;
      rpc-bind-address = "0.0.0.0";
      rpc-host-whitelist = net.junction.name;
      rpc-whitelist = "${net.home.baseIP}.*, ${net.wireguard.baseIP}.*";
    };
  };
}

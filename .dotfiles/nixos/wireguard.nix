{ lib, ... }:

let
  port = 51820;
  privateKeyFile = "/etc/wireguard/private";
  generatePrivateKeyFile = true;
  gateway = {
    ip = "10.100.0.1";
    # Run `sudo cat /etc/wireguard/private | wg pubkey` and update this value after re-provisioning
    publicKey = "70NDFa+EmxNDZLW3QFO3blILT3oRA5K3aIofjLPdIxg=";
    initialIP = "49.12.239.37"; # The static IP the server can be reached at
  };
  horse = {
    ip = "10.100.0.8";
    publicKey = "adcMoJUfbf+RTtRt6oXCggop1XDWGfiWyGQzA9gmpB0=";
  };
  junction = {
    ip = "10.100.0.13";
    publicKey = "7nVUiBWzttk7FYDNNZ/wddzcVvUU3Fsrpc3+E/hNqjU=";
  };
  makeIps = a: [ "${a.ip}/24" ];
  makePeer = a: {
    inherit (a) publicKey;
    allowedIPs = [ "${a.ip}/32" ];
  };
  makeServer = a: additionalOpts: {
    inherit (a) publicKey;
    allowedIPs = [ "0.0.0.0/0" ];
    endpoint = "${a.initialIP}:${builtins.toString port}";
  } // additionalOpts;
in
{
  gateway = {
    config = {
      networking.nat.enable = true;
      networking.nat.externalInterface = "eth0";
      networking.nat.internalInterfaces = [ "wg0" ];
      networking.firewall = {
        allowedUDPPorts = [ port ];
      };

      networking.wireguard.interfaces = {
        wg0 = {
          ips = makeIps gateway;
          inherit privateKeyFile generatePrivateKeyFile;
          listenPort = port;
          peers = [
            (makePeer junction)
            (makePeer horse)
          ];
        };
      };
    };
  };
  junction = {
    config = {
      networking.wireguard.interfaces = {
        wg0 = {
          ips = makeIps junction;
          inherit privateKeyFile generatePrivateKeyFile;
          listenPort = port;
          peers = [
            (makeServer gateway {
              # junction hosts services that need to be accessible 24/7
              # sending a periodic keepalive signal ensures gateway always
              # knows its current IP. This roaming is part of wireguard.
              persistentKeepalive = 25;
            })
          ];
        };
      };
    };
  };
}

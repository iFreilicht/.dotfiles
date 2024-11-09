let
  net = import ./network.nix;
  gateway = net.gateway.wireguard;
  junction = net.junction.wireguard;
  horse = net.horse.wireguard;
  source = net.source.wireguard;
  uhl'siphone = net.uhl'siphone.wireguard;
  DESKTOP-O2898M0 = net.DESKTOP-O2898M0.wireguard;

  port = 51820;
  privateKeyFile = "/etc/wireguard/private";
  makeIps = a: [ "${a.ip}/24" ];
  makePeer = a: {
    inherit (a) publicKey;
    allowedIPs = [ "${a.ip}/32" ];
  };
  makeServer =
    a: additionalOpts:
    {
      inherit (a) publicKey;
      allowedIPs = [ a.subnet ];
      endpoint = "${a.initialIP}:${builtins.toString port}";
    }
    // additionalOpts;
in
{
  peers = {
    inherit junction gateway;
  };
  gateway = {
    config = {
      networking.nat.enable = true;
      networking.nat.externalInterface = "eth0";
      networking.nat.internalInterfaces = [ "wg0" ];
      networking.firewall = {
        allowedUDPPorts = [ port ];
      };

      networking.wg-quick.interfaces = {
        wg0 = {
          address = makeIps gateway;
          inherit privateKeyFile;
          generatePrivateKeyFile = true;
          listenPort = port;
          peers = [
            (makePeer junction)
            (makePeer horse)
            (makePeer source)
            (makePeer uhl'siphone)
            (makePeer DESKTOP-O2898M0)
          ];
        };
      };
    };
  };
  junction = {
    config = {
      networking.firewall = {
        allowedUDPPorts = [ port ];
      };

      networking.wg-quick.interfaces = {
        wg0 = {
          address = makeIps junction;
          inherit privateKeyFile;
          generatePrivateKeyFile = true;
          listenPort = port;
          # FTP doesn't work with the default MTU of 1420. I saw suggestions for 1200 and 1360,
          # and both worked. I assume 1360 is faster because the fragmentation is lower, but I
          # don't quite understand the details enough to actually know.
          mtu = 1360;
          peers = [
            (makeServer gateway {
              # junction hosts services that need to be accessible 24/7
              # sending a periodic keepalive signal ensures gateway always
              # knows its current IP. This roaming is part of wireguard.
              # Setting this to 1 should minimize the maximum downtime on a public IP change,
              # but the usual recommendation is 25, which seems fine for non-critical devices.
              persistentKeepalive = 1;
            })
          ];
        };
      };
    };
  };
  horse = {
    networking.wg-quick.interfaces = {
      wg0 = {
        address = makeIps horse;
        listenPort = port;
        dns = [
          gateway.ip
          "gateway"
        ]; # IP is the DNS server, hostname is the search domain
        privateKey = "AAAA-Replace-with-real-key-AAAA";
        peers = [ (makeServer gateway { }) ];
      };
    };
  };
  DESKTOP-O2898M0.networking.wg-quick.interfaces.wg0 = {
    address = makeIps DESKTOP-O2898M0;
    listenPort = port;
    dns = [ ]; # No DNS, junction will be accessed via IP
    privateKey = "AAAA-Replace-with-real-key-AAAA";
    peers = [ (makeServer gateway { }) ];
  };
  source = {
    config = {
      networking.firewall = {
        allowedUDPPorts = [ port ];
      };

      networking.wg-quick.interfaces = {
        wg0 = {
          address = makeIps source;
          inherit privateKeyFile;
          generatePrivateKeyFile = true;
          listenPort = port;
          peers = [ (makeServer gateway { }) ];
        };
      };
    };
  };
}

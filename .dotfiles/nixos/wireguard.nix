let
  net = import ./network.nix;
  gateway = net.gateway.wireguard;
  junction = net.junction.wireguard;
  horse = net.horse.wireguard;
  uhl'siphone = net.uhl'siphone.wireguard;

  port = 51820;
  privateKeyFile = "/etc/wireguard/private";
  makeIps = a: [ "${a.ip}/24" ];
  makePeer = a: {
    inherit (a) publicKey;
    allowedIPs = [ "${a.ip}/32" ];
  };
  makeServer = a: additionalOpts: {
    inherit (a) publicKey;
    allowedIPs = [ a.subnet ];
    endpoint = "${a.initialIP}:${builtins.toString port}";
  } // additionalOpts;

  # I stole this script from nixpkgs nixos/modules/services/networking/wireguard.nix
  # because nixos/modules/services/networking/wg-quick.nix doesn't have a generatePrivateKeyFile option yet.
  # I'm trying to get this upstreamed in https://github.com/NixOS/nixpkgs/pull/331253
  createPrivateKey = ''
    set -e
    mkdir -p --mode 0755 "${dirOf privateKeyFile}"
    if [ ! -f "${privateKeyFile}" ]; then
      # Write private key file with atomically-correct permissions.
      (set -e; umask 077; wg genkey > "${privateKeyFile}")
    fi
  '';
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
          preUp = createPrivateKey;
          listenPort = port;
          peers = [
            (makePeer junction)
            (makePeer horse)
            (makePeer uhl'siphone)
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
          preUp = createPrivateKey;
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
  horse = {
    networking.wg-quick.interfaces = {
      wg0 = {
        address = makeIps horse;
        listenPort = port;
        privateKey = "AAAA-Replace-with-real-key-AAAA";
        peers = [
          (makeServer gateway { })
        ];
      };
    };
  };
}

{ lib, ... }:

let
  port = 51820;
  privateKeyFile = "/etc/wireguard/private";
  gateway = {
    ip = "10.100.0.1";
    # ON REINSTALL: Run `sudo cat /etc/wireguard/private | wg pubkey` and update this value
    publicKey = "70NDFa+EmxNDZLW3QFO3blILT3oRA5K3aIofjLPdIxg=";
    initialIP = "49.12.239.37"; # The static IP the server can be reached at
  };
  horse = {
    ip = "10.100.0.8";
    publicKey = "adcMoJUfbf+RTtRt6oXCggop1XDWGfiWyGQzA9gmpB0=";
  };
  junction = {
    ip = "10.100.0.13";
    # ON REINSTALL: Run `sudo cat /etc/wireguard/private | wg pubkey` and update this value
    publicKey = "ocMusNfO8N6z4kc2FEJMwhFTdRV4VWbKyAhGZMDzJSE=";
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
}

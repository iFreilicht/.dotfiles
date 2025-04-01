{ ... }:
let
  # ON REINSTALL: Run `cat /etc/wireguard/mullvad-private` and register it in mullvad
  privateKeyFile = "/etc/wireguard/mullvad-private";
in
{
  # Enable mullvad VPN so my IP doesn't leak
  services.mullvad-vpn.enable = true;

  networking.wg-quick.interfaces.wg1 = {
    address = [
      "10.66.208.107/32"
      "fc00:bbbb:bbbb:bb01::3:d06a/128"
    ];
    dns = [ "10.64.0.1" ];
    inherit privateKeyFile;
    generatePrivateKeyFile = true;

    peers = [
      {
        publicKey = "uKTC5oP/zfn6SSjayiXDDR9L82X0tGYJd5LVn5kzyCc=";
        allowedIPs = [
          "0.0.0.0/0"
          "::0/0"
        ];
        endpoint = "146.70.107.194:51820";
      }
    ];
  };
}

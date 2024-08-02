{
  nextcloud = { domain = "cloud2.uhl.cx"; port = 33001; };
  snapdrop = { domain = "drop.uhl.cx"; port = 33002; };
  gateway = {
    wireguard = {
      ip = "10.100.0.1";
      # ON REINSTALL: Run `sudo cat /etc/wireguard/private | wg pubkey` and update this value
      publicKey = "70NDFa+EmxNDZLW3QFO3blILT3oRA5K3aIofjLPdIxg=";
      initialIP = "49.12.239.37"; # The static IP the server can be reached at
    };
  };
  junction = {
    wireguard = {
      ip = "10.100.0.13";
      # ON REINSTALL: Run `sudo cat /etc/wireguard/private | wg pubkey` and update this value
      publicKey = "ocMusNfO8N6z4kc2FEJMwhFTdRV4VWbKyAhGZMDzJSE=";
    };
  };
  horse = {
    ssh.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9OOXhRhYgpaFLwbkfcQsSYYUTr+qsbf0WIHcUm2fFQ felix@horse";
    wireguard = {
      ip = "10.100.0.8";
      publicKey = "adcMoJUfbf+RTtRt6oXCggop1XDWGfiWyGQzA9gmpB0=";
    };
  };
  source.ssh.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0TI3HN6e00Bv29ui7BUCYSa4FBjcWBs4fE5R1ODc9+ felix@source";
}

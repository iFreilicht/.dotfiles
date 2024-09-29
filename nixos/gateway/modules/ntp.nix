{ ... }:
{
  services.chrony = {
    enable = true;
    extraConfig = ''
      allow
    '';
  };

  networking.firewall.allowedUDPPorts = [ 123 ];
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:
let
  net = import ../network.nix;
in
{
  imports =
    [
      ../common.nix
      ./hardware-configuration.nix # Include the results of the hardware scan.
      (import ../wireguard.nix { inherit (pkgs) lib; }).gateway
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "gateway";

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 1 * 1024; # Half of available RAM
  }];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  users.users.felix = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      net.horse.ssh.publicKey
      net.source.ssh.publicKey
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  # Allow my own user to use sudo without a password. This works around an issue with remote nixos-rebuild switch,
  # see https://discourse.nixos.org/t/remote-nixos-rebuild-works-with-build-but-not-with-switch/34741/7?u=ifreilicht
  security.sudo.wheelNeedsPassword = false;

  # Automatically renewing SSL certificates
  security.acme = {
    defaults.email = "letsencrypt@mail.felix-uhl.de";
    acceptTerms = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    # Harden nginx as described in https://nixos.wiki/wiki/nginx#Hardened_setup_with_TLS_and_HSTS_preloading
    # Not all settings from the article are compatible with nextcloud.
    appendHttpConfig = ''
      # Add HSTS header with preloading to HTTPS requests.
      # Adding this header to HTTP requests is discouraged
      map $scheme $hsts_header {
          https   "max-age=31536000; includeSubdomains";
      }
      add_header Strict-Transport-Security $hsts_header;

      # Enable CSP
      add_header Content-Security-Policy "object-src 'none'; base-uri 'none';" always;

      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';
    '';

    virtualHosts."${net.nextcloud.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://${net.junction.wireguard.ip}:${toString net.nextcloud.port}";
    };
    virtualHosts."${net.snapdrop.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${net.junction.wireguard.ip}:${toString net.snapdrop.port}";
        proxyWebsockets = true;
      };
    };
    virtualHosts."${net.kritzeln.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${net.junction.wireguard.ip}:${toString net.kritzeln.port}";
        proxyWebsockets = true;
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}


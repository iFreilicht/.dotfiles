# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ net, wireguard, ... }:
{
  imports = [
    ../common.nix
    ../modules/machine-type.nix
    ../modules/use-remote-builders.nix
    ../modules/user-felix.nix
    ./modules/hardware-configuration.nix # Include the results of the hardware scan.
    wireguard.gateway
    # Modules for services
    ./modules/dns.nix
    ./modules/fail2ban.nix
    ./modules/nginx.nix
    ./modules/ntp.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "gateway";
  uhl.machineType = "server";

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 1 * 1024; # Half of available RAM
    }
  ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  felix.authorizedKeys = [
    net.horse.felix.publicKey
    net.source.felix.publicKey
  ];

  # Allow my own user to use sudo without a password. This works around an issue with remote nixos-rebuild switch,
  # see https://discourse.nixos.org/t/remote-nixos-rebuild-works-with-build-but-not-with-switch/34741/7?u=ifreilicht
  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Use less than all available cores when building to avoid overloading the system.
  # In general, I don't want to build anything that needs compiling on this system at all,
  # but it sometimes happens by accident. Having this limit ensures I can easily abort builds.
  nix.settings.cores = 1;
  uhl.useRemoteBuilders = [
    "source"
    "junction"
  ];

  # Enable automatic access to all services via wireguard
  uhl.dns.entries = {
    ${net.nextcloud.subDomain} = net.junction.wireguard.ip;
    ${net.snapdrop.subDomain} = net.junction.wireguard.ip;
    ${net.kritzeln.subDomain} = net.junction.wireguard.ip;
    ${net.git.subDomain} = net.junction.wireguard.ip;
    ${net.home-assistant.subDomain} = net.junction.wireguard.ip;
    ${net.pihole.subDomain} = net.junction.wireguard.ip;
    ${net.transmission.subDomain} = net.junction.wireguard.ip;
    ${net.jellyfin.subDomain} = net.junction.wireguard.ip;
    ${net.gitlab.subDomain} = net.junction.wireguard.ip;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

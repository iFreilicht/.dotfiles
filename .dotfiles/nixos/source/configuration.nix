{ config, lib, pkgs, net, ... }:

{
  imports = [
    ../common.nix
    ../modules/user-felix.nix
    ../modules/extra-boot-options.nix
    ./modules/hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    systemd-boot.edk2-uefi-shell.enable = true;
    systemd-boot.windows."Windows 10".efiDeviceHandle = "FS1";
  };

  # Ensure clock is synchronized between Windows and Linux
  time.hardwareClockInLocalTime = true;

  networking.hostName = "source";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  felix.authorizedKeys = [
    net.horse.felix.publicKey
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true; # Optional, but I might want to use X11 for some applications.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  users.mutableUsers = lib.mkForce true; # Allow users to change their own passwords
  users.users.felix = {
    initialPassword = "changeimmediately";
    packages = with pkgs; [
      firefox
      nextcloud-client
      keepassxc
      vorta
      vscode
      joplin-desktop
    ];
  };

  environment.systemPackages = with pkgs; [
    kitty
    python3
  ];

  # Unlock GnuPG and SSH keys on login
  programs = {
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.callPackage ../packages/pinentry-kwallet.nix { };
    };
    ssh.startAgent = true;
  };
  security.pam.services.sshd.kwallet.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}


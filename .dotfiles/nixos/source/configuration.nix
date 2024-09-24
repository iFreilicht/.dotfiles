{ config, lib, pkgs, net, ... }:

{
  imports = [
    ../common.nix
    ../modules/user-felix.nix
    ./modules/hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    # Copy EDK2 Shell to boot partition
    systemd-boot.extraFiles."efi/shell.efi" = "${pkgs.edk2-uefi-shell}/shell.efi";
    systemd-boot.extraEntries = let
      # To determine the name of the windows boot drive, boot into edk2 first, then run
      # `map -c` to get drive aliases, and try out running `FS1:`, then `ls EFI` to check
      # which alias corresponds to which EFI partition.
      boot-drive = "FS1";
    in {
      # Chainload Windows bootloader via EDK2 Shell
      "windows.conf" = ''
        title Windows Bootloader
        efi /efi/shell.efi
        options -nointerrupt -nomap -noversion ${boot-drive}:EFI\Microsoft\Boot\Bootmgfw.efi
        sort-key y_windows
      '';
      # Make EDK2 Shell available as a boot option
      "edk2-uefi-shell.conf" = ''
        title EDK2 UEFI Shell
        efi /efi/shell.efi
        sort-key z_edk2
      '';
    };
  };

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
    ];
  };

  environment.systemPackages = with pkgs; [
    kitty
  ];

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

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


# Options I want to enable on every system
{ config, pkgs, ... }:

{
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    zip
  ];
  # Make vim the default editor
  environment.variables.EDITOR = pkgs.vim;

  # Programs with configuration
  programs.zsh.enable = true;

}

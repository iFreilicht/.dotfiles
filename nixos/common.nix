# Options I want to enable on every system
{
  pkgs,
  nixpkgs,
  lix-module,
  ...
}:

{
  imports = [ lix-module.nixosModules.lixFromNixpkgs ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Nix settings
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    # Lock 'nixpkgs' in flake-refs to the same nixpkgs this configuration is built from
    # This prevents downloads of newer versions of nixpkgs when using `nix shell` or `nix run`
    # (This seems to be the default in 24.05, but not earlier versions)
    registry = {
      nixpkgs = {
        from = {
          type = "indirect";
          id = "nixpkgs";
        };
        to = {
          type = "path";
          path = nixpkgs;
        };
      };
    };
  };

  # Manage users and their passwords fully declaratively
  users.mutableUsers = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    zip
  ];

  environment.variables = {
    # Make vim the default editor
    EDITOR = pkgs.vim;
    # Used by nh to determine the default flake to use
    FLAKE = "/home/felix/.dotfiles";
  };

  # Programs with configuration
  programs.zsh.enable = true;

}

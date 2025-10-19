# Options I want to enable on every system
{
  pkgs,
  nixpkgs,
  ...
}:

{
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
  # Nix settings
  nix = {
    # Use Lix instead of NixCpp
    package = pkgs.lixPackageSets.stable.lix;

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

  # Ensure tools relying on NixCpp use Lix instead
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

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
    NH_FLAKE = "/home/felix/.dotfiles";
  };

  # Programs with configuration
  programs.zsh.enable = true;

}

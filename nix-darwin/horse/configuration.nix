{
  pkgs,
  ...
}:

{
  environment.variables = {
    # Make vim the default editor
    EDITOR = pkgs.vim;
    # Used by nh to determine the default flake to use
    NH_FLAKE = "/Users/feuh/.dotfiles";
  };

  # Use Lix
  nix = {
    enable = true;
    package = pkgs.lixPackageSets.stable.lix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
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

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}

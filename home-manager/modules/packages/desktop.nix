# Files I want available on desktops only
{
  nixosConfig,
  pkgs,
  pkgs-stable,
  ...
}:
let
  lib = pkgs.lib;
  machineType = nixosConfig.uhl.machineType or "desktop";

  defaultPackages =
    (with pkgs-stable; [
    ])
    ++ (with pkgs; [
      # Basic terminal setup
      direnv # Automatically switch environments in development folders

      # Some utilities
      imagemagick # Image processing

      # Programming stuff
      asdf-vm # Version manager for all sorts of tools
      # Run `asdf plugin-add direnv` afterwards to enable integration with direnv
      # TODO: Enable direnv integration automatically
      git-absorb # Easier fixup-rebase workflow for git
      gh # GitHub CLI
      sops # Store secrets safely in git repositories
      sqlfluff # SQL linter and formatter
      opentofu # IAC, open-source fork of Terraform

      # Nix stuff
      nixos-rebuild # Even on macOS and non-Nix linux for remote deployments
      nixfmt-rfc-style # Autoformatter for Nix
      nixpkgs-fmt # Another autoformatter, specific to nixpkgs
      nixd # Nix LSP language server

      # Containers
      docker # Container management CLI
      docker-compose # Container composition
      dive # Inspecting image contents without starting a container
    ]);
in
{
  imports = [
    ./clipboard-jh.nix
  ];

  home.packages = lib.lists.optionals (machineType == "desktop") defaultPackages;
}

# Files I want available on desktops only
{
  config,
  pkgs,
  pkgs-stable,
  ...
}:
let
  lib = pkgs.lib;
  system = pkgs.stdenv.system;

  defaultPackages =
    (with pkgs-stable; [
      tlrc # Quick command help, tldr rust client. Command is tldr, not tlrc
    ])
    ++ (with pkgs; [
      # Basic terminal setup
      direnv # Automatically switch environments in development folders
      grc # Colouring output of some default utilities
      autojump # Jump to often-visited directories quickly
      fzf # Fuzzy search command history
      zellij # Split views and sessions

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
      thefuck # Quickly correct common mistakes when typing commands
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

  home.packages = lib.lists.optionals (config.uhl.machineType == "desktop") (
    defaultPackages
    ++ lib.lists.optionals (lib.strings.hasInfix "darwin" system) (
      with pkgs;
      [
        # The nix version somehow doesn't honor UTF-8 locales on linux, use the distro's version instead
        zsh
      ]
    )
  );
}

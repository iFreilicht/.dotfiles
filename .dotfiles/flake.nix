# To install these packages via nix, run:
#     nix run path:$HOME/.dotfiles#profile.switch

# I also recommend pinning the flakes registry and channels to avoid unnecessary downloads:
#     nix run path:$HOME/.dotfiles#profile.pin

# To use nix flake commands, you'll also have to refer to this flake by path (because of the bare repo, see README.md):
#     nix flake show path:$HOME/.dotfiles

{
  description = "Default packages to install into user environment";

  inputs = {
    flakey-profile.url = "github:lf-/flakey-profile";
    # `nix flake update` always upgrades nixpkgs to the latest version as well, which is annoying,
    # as I need to download nixpkgs again AND risk breakage. Lock the exact commit instead for both
    # stable and unstable. Stable is only required when unstable breaks (which happens often on darwin)
    # To upgrade, check https://hydra.nixos.org/jobset/nixpkgs/trunk for unstable
    # and https://hydra.nixos.org/jobset/nixpkgs/nixpkgs-23.11-darwin for stable
    # and select the latest commit hash that has no unfinished builds (meaning it's fully cached).
    # Use `git rev-parse 53a2c32` in a local nixpkgs checkout to find the full hash quickly.
    nixpkgs.url = "github:NixOS/nixpkgs/3281bec7174f679eabf584591e75979a258d8c40";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/d52be12b079045912fdfaa027f29c826e9a23e31";
    # Nextcloud 27 is currently broken in unstable (24.05), so I need 23.11 for junction
    nixpkgs-23_11.url = "github:NixOS/nixpkgs/27c13997bf450a01219899f5a83bd6ffbfc70d3c";

    nix.url = "github:NixOS/nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixd.url = "github:nix-community/nixd";
  };

  outputs = { self, flakey-profile, nixpkgs, nixpkgs-stable, nixpkgs-23_11, nix, flake-utils, nixd }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-stable = nixpkgs-stable.legacyPackages.${system};
        defaultPackages = {
          inherit (pkgs-stable)
            # Utilities
            ncdu# Disk usage analyzer
            # Programming stuff
            sqlfluff# SQL linter and formatter
            ;
          inherit (pkgs)
            # Basic terminal setup
            coreutils# Use consistent coreutils accross all platforms
            gnused# Use GNU sed on all platforms
            zsh-powerlevel10k# ZSH theme
            zsh-syntax-highlighting# Syntax highlighting when typing commands
            zsh-completions# Additional completions for ZSH
            direnv# Automatically switch environments in development folders
            grc# Colouring output of some default utilities
            autojump# Jump to often-visited directories quickly
            fzf# Fuzzy search command history
            zellij# Split views and sessions
            clipboard-jh# Clipboard integration for X11, Wayland, macOS, Windows and OSC 52

            # Some utilities
            git-absorb# Easier fixup-rebase workflow for git
            bat# Colorized file output
            fd# Alternative to find, easier to use
            ripgrep# Alternative to grep, much quicker, uses regex by default
            jq# Formatting and querrying JSON strings
            moreutils# Additional useful utils. Especially sponge
            tree# Show directory tree
            pv# Monitor progress of piped data
            httpie# Modern curl alternative
            thefuck# Quickly correct common mistakes when typing commands
            imagemagick# Image processing
            btop# Richer resource monitor, alternative to htop
            ranger# Fast navigation through directory tree
            gnupg# PGP toolkit
            tlrc# Quick command help, tldr rust client. Command is tldr, not tlrc
            duf# Quick disk space view

            # Programming stuff
            asdf-vm# Version manager for all sorts of tools
            # Run `asdf plugin-add direnv` afterwards to enable integration with direnv
            # TODO: Enable direnv integration automatically
            gh# GitHub CLI

            # Nix stuff
            nh# Nix helper, very useful!
            nix-output-monitor# Much better view of build status
            nvd# Comprehensive difference between two derivations, especially helpful for profiles
            nixos-rebuild# Even on macOS and non-Nix linux for remote deployments
            nixfmt-classic# Autoformatter for Nix
            nixpkgs-fmt# Another autoformatter, specific to nixpkgs

            # Containers
            docker# Container management CLI
            docker-compose# Container composition
            colima# Backend for Linux and macOS, which docker daemon isn't. Run `colima start`
            dive# Inspecting image contents without starting a container
            ;
          nix = nix.packages.${system}.default;
          nixd = nixd.packages.${system}.default;
          vim = (import (./nix/vim.nix) { inherit pkgs; });

        };
        linuxPackages = with pkgs; {
          inherit
            # MacOS git supports unlocking with keychain, which is conventient
            git# Version management. Consistent version means access to new features on all platforms/distros.
            ;
        };
        darwinPackages = with pkgs; {
          inherit
            # The nix version somehow doesn't honor UTF-8 locales on linux, use the distro's version instead
            zsh;
        };
        systemPackages = defaultPackages
        // (if (pkgs.lib.strings.hasInfix "linux" system) then
          linuxPackages
        else
          { }) // (if (pkgs.lib.strings.hasInfix "darwin" system) then
          darwinPackages
        else
          { });
        packageListString =
          pkgs.lib.strings.concatMapStringsSep "\n" (x: "${x}")
            (builtins.attrValues systemPackages);
      in
      {
        packages.profile = flakey-profile.lib.mkProfile {
          inherit pkgs;
          paths = builtins.attrValues systemPackages;
          pinned = {
            nixpkgs = toString nixpkgs;
            stable = toString nixpkgs-stable;
          };
        };
      })
    )
    //
    {
      nixosConfigurations = {
        junction = nixpkgs-23_11.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./nixos/junction/configuration.nix
          ];
        };

        gateway = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./nixos/gateway/configuration.nix
          ];
        };
      };
    }
  ;
}


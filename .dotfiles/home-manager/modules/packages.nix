{ pkgs, pkgs-stable, ... }:
let
  lib = pkgs.lib;
  system = pkgs.stdenv.system;

  vim = (import ./vim.nix { inherit pkgs; });

  # This is a small hack to get the vimrc file into the profile so I can point vscode to it
  vimRc = pkgs.runCommandNoCC "custom-vimrc" { } ''
    mkdir -p $out/share/
    ln -s $(cat ${vim}/bin/vim | grep -oP "(?<=')[^']+(?=')") $out/share/custom-vimrc
  '';

  defaultPackages =
    (with pkgs-stable; [
      tlrc # Quick command help, tldr rust client. Command is tldr, not tlrc
    ])
    ++ (with pkgs; [
      # Basic terminal setup
      coreutils # Use consistent coreutils accross all platforms
      gnused # Use GNU sed on all platforms
      zsh-powerlevel10k # ZSH theme
      zsh-syntax-highlighting # Syntax highlighting when typing commands
      zsh-completions # Additional completions for ZSH
      direnv # Automatically switch environments in development folders
      grc # Colouring output of some default utilities
      autojump # Jump to often-visited directories quickly
      fzf # Fuzzy search command history
      zellij # Split views and sessions

      # Some utilities
      git-absorb # Easier fixup-rebase workflow for git
      bat # Colorized file output
      fd # Alternative to find, easier to use
      ripgrep # Alternative to grep, much quicker, uses regex by default
      jq # Formatting and querrying JSON strings
      moreutils # Additional useful utils. Especially sponge
      tree # Show directory tree
      pv # Monitor progress of piped data
      httpie # Modern curl alternative
      thefuck # Quickly correct common mistakes when typing commands
      imagemagick # Image processing
      btop # Richer resource monitor, alternative to htop
      ranger # Fast navigation through directory tree
      gnupg # PGP toolkit
      age # Encryption tool
      duf # Quick disk space view
      ncdu # Disk usage analyzer

      # Programming stuff
      asdf-vm # Version manager for all sorts of tools
      # Run `asdf plugin-add direnv` afterwards to enable integration with direnv
      # TODO: Enable direnv integration automatically
      gh # GitHub CLI
      sops # Store secrets safely in git repositories
      sqlfluff # SQL linter and formatter
      opentofu # IAC, open-source fork of Terraform

      # Nix stuff
      nh # Nix helper, very useful!
      nix-output-monitor # Much better view of build status
      nvd # Comprehensive difference between two derivations, especially helpful for profiles
      nixos-rebuild # Even on macOS and non-Nix linux for remote deployments
      nixfmt-rfc-style # Autoformatter for Nix
      nixpkgs-fmt # Another autoformatter, specific to nixpkgs
      nixd # Nix LSP language server

      # Containers
      docker # Container management CLI
      docker-compose # Container composition
      colima # Backend for Linux and macOS, which docker daemon isn't. Run `colima start`
      dive # Inspecting image contents without starting a container
    ])
    ++ [
      vim
      vimRc
    ];
in
{
  home.packages =
    defaultPackages
    ++ lib.optionals (lib.strings.hasInfix "linux" system) (
      with pkgs;
      [
        # MacOS git supports unlocking with keychain, which is conventient
        git # Version management. Consistent version means access to new features on all platforms/distros.
        # Clipboard has a bug on Wayland, use custom fix from https://github.com/Slackadays/Clipboard/pull/203
        (clipboard-jh.overrideAttrs (oldAttrs: {
          version = "0.9.0.2+pre+fix_wayland_flicker";
          src = fetchFromGitHub {
            owner = "iFreilicht";
            repo = "Clipboard";
            rev = "15bb982412e3134a09eab28d8c27d9a60f5f9aef";
            hash = "sha256-g0YNnpqpGx17j4JzGVgDWanY0AqNtTfUffh9IKon0rc=";
          };
          buildInputs = oldAttrs.buildInputs ++ [ pkgs.openssl ];
        }))
      ]
    )
    ++ lib.lists.optionals (lib.strings.hasInfix "darwin" system) (
      with pkgs;
      [
        # The nix version somehow doesn't honor UTF-8 locales on linux, use the distro's version instead
        zsh
        clipboard-jh # Clipboard integration for X11, Wayland, macOS, Windows and OSC 52
      ]
    );
}

# Files I want available on servers and desktops
{ pkgs, pkgs-stable, ... }:
let
  defaultPackages =
    (with pkgs-stable; [
    ])
    ++ (with pkgs; [
      # Basic terminal setup
      coreutils # Use consistent coreutils accross all platforms
      gnused # Use GNU sed on all platforms
      zsh-powerlevel10k # ZSH theme
      zsh-syntax-highlighting # Syntax highlighting when typing commands
      zsh-completions # Additional completions for ZSH
      grc # Colouring output of some default utilities
      autojump # Jump to often-visited directories quickly
      fzf # Fuzzy search command history
      zellij # Split views and sessions

      # Some utilities
      bat # Colorized file output
      fd # Alternative to find, easier to use
      ripgrep # Alternative to grep, much quicker, uses regex by default
      jq # Formatting and querrying JSON strings
      moreutils # Additional useful utils. Especially sponge
      tree # Show directory tree
      pv # Monitor progress of piped data
      httpie # Modern curl alternative
      btop # Richer resource monitor, alternative to htop
      ranger # Fast navigation through directory tree
      gnupg # PGP toolkit
      age # Encryption tool
      duf # Quick disk space view
      ncdu # Disk usage analyzer
      tlrc # Quick command help, tldr rust client. Command is tldr, not tlrc

      # Programming stuff
      fossil # Minimal version control system

      # Nix stuff
      nh # Nix helper, very useful!
      nix-output-monitor # Much better view of build status
      nvd # Comprehensive difference between two derivations, especially helpful for profiles
      nix-top # Monitor nix builds
    ]);
in
{
  imports = [
    ./clipboard-jh.nix
  ];

  home.packages = defaultPackages;
}

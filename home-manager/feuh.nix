{ pkgs, ... }:
{
  imports = [
    ../nixos/modules/machine-type.nix
    ./modules/aliases.nix
    ./modules/config-files
    ./modules/env.nix
    ./modules/fonts
    ./modules/git.nix
    ./modules/home-files
    ./modules/nushell
    ./modules/packages
    ./modules/packages/desktop.nix
    ./modules/registry.nix
    ./modules/ssh.nix
    ./modules/vim.nix
    ./modules/zsh
  ];

  home.username = "feuh";
  home.homeDirectory = "/Users/feuh";
  home.sessionPath = [
    "$HOME/.local/bin" # Useful for pipx
  ];

  # MacOS git supports unlocking with keychain, which is conventient and not supported in any
  # git version shipped with nix. We can't use programs.git.enable = false, because that would
  # cause the git configuration from home-manager to not be written at all
  programs.git.package = pkgs.writeShellScriptBin "use-system-git" "git $@";

  home.file = {

  };

  home.sessionVariables = {
    # Used by nh to determine the default flake to use
    FLAKE = "/Users/feuh/.dotfiles";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

}

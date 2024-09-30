{ ... }:
{
  imports = [
    ./modules/aliases.nix
    ./modules/config-files
    ./modules/env.nix
    ./modules/fonts
    ./modules/git.nix
    ./modules/home-files
    ./modules/packages
    ./modules/registry.nix
    ./modules/ssh.nix
    ./modules/vim.nix
    ./modules/zsh.nix
  ];

  home.username = "felix";
  home.homeDirectory = "/home/felix";

  home.file = {

  };

  home.sessionVariables = {
    # Fix perl locale warnings (they never matter and are always annoying to fix)
    PERL_BADLANG = 0;
    # Make sure programs know about vim
    EDITOR = "$HOME/.nix-profile/bin/vim";
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

{ ... }:
{
  home.sessionVariables = {
    # Fix perl locale warnings (they never matter and are always annoying to fix)
    PERL_BADLANG = 0;
    # Make sure programs know about vim
    EDITOR = "$HOME/.nix-profile/bin/vim";
  };
}

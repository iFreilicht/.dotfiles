# Source further files from custom directory
export ZDOTDIR="$HOME/.config/zsh"

# Fix perl locale warnings (they never matter and are always annoying to fix)
export PERL_BADLANG=0

# Make sure programs know about vim
export EDITOR="/usr/bin/vim"
if [ -e /home/felix/.nix-profile/etc/profile.d/nix.sh ]; then . /home/felix/.nix-profile/etc/profile.d/nix.sh; fi

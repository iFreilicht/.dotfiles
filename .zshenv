# Source further files from custom directory
export ZDOTDIR="$HOME/.config/zsh"

# Make sure programs know about vim
export EDITOR="/usr/bin/vim"
if [ -e /home/felix/.nix-profile/etc/profile.d/nix.sh ]; then . /home/felix/.nix-profile/etc/profile.d/nix.sh; fi

# Make sure instant prompt doesn't throw a warning if direnv hook is run on startup
emulate zsh -c "$(direnv export zsh)"

# Colourful output for a lot of additional utilities.
# Needs to be sourced before instant prompt, otherwise it doesn't work
[ -e "$HOME/.nix-profile/etc/grc.zsh" ] && source $HOME/.nix-profile/etc/grc.zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Get aliases
source $ZDOTDIR/aliases

# Source private zshrc if it exists
if [ -f "$ZDOTDIR/private" ]; then
    source "$ZDOTDIR/private"
fi

# Enable a list of options
source $ZDOTDIR/keybinds

# Enable a list of options
source $ZDOTDIR/options

# Set history options
HISTSIZE=100000
HISTFILESIZE=200000
SAVEHIST=100000
HISTFILE=~/.cache/zsh/history
setopt appendhistory
# Ensure the history file is present
mkdir -p $(dirname $HISTFILE)
touch $HISTFILE

# Let direnv hook into zsh. Used especially for nix
eval "$(direnv hook zsh)"

# Autojump needs to be sourced to work on Ubuntu
source /usr/share/autojump/autojump.zsh

# Source node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Source cargo
[ -s "$HOME/.cargo/env" ] && source $HOME/.cargo/env

# Source nix
[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Source ROS
[ -e "/opt/ros/melodic/setup.zsh" ] && source "/opt/ros/melodic/setup.zsh"

# Broot is better run as br for functionality reasons
[ -e "$HOME/.config/broot" ] && source $HOME/.config/broot/launcher/bash/br

# ZSH syntax highlighting. This should be sourced last!
source $HOME/.dotfiles/run/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Source fzf
source $HOME/.config/fzf/zsh

# Make sure vim is the default editor
export EDITOR='vim'
export VISUAL='vim'

# Activate p10k
source $HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

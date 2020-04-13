# Get all the oh-my-zsh stuff running
source $ZDOTDIR/oh-my-zsh

# Get aliases
source $ZDOTDIR/aliases

# Source private zshrc if it exists
if [ -f "$ZDOTDIR/private" ]; then
    source "$ZDOTDIR/private"
fi

# Configure tab completion
compinit
setopt globdots

# Autojump needs to be sourced to work on Ubuntu
source /usr/share/autojump/autojump.sh

# Source node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Broot is better run as br for functionality reasons
source $HOME/.config/broot/launcher/bash/br

# ZSH syntax highlighting. This should be sourced last!
source $HOME/.dotfiles/run/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

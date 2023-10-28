# Source nix. Try to source global default profile first, then the per-user profile.
# This is a workaround for https://github.com/NixOS/nix/issues/3616
#[[ "$(whence vim)" != "$HOME/.nix-profile/bin/vim" ]]

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

# Enable all autocompletions for nix-installed tools
for p in ${(z)NIX_PROFILES}; do
  fpath+=($p/share/zsh/site-functions $p/share/zsh/$ZSH_VERSION/functions $p/share/zsh/vendor-completions)
done

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

# Enable thefuck alias
eval $(thefuck --alias)

# Autojump needs to be sourced to work on Ubuntu
source $HOME/.nix-profile/share/autojump/autojump.zsh

# Source node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Source cargo
[ -s "$HOME/.cargo/env" ] && source $HOME/.cargo/env

# Source ROS
[ -e "/opt/ros/melodic/setup.zsh" ] && source "/opt/ros/melodic/setup.zsh"

# Source gcloud stuff if available
if [[ ! $(command -v gcloud) && -e "$HOME/Documents/Apps/google-cloud-sdk/" ]]; then
  source "$HOME/Documents/Apps/google-cloud-sdk/path.zsh.inc"
  source "$HOME/Documents/Apps/google-cloud-sdk/completion.zsh.inc"
fi

# Broot is better run as br for functionality reasons
[ -e "$HOME/.config/broot" ] && source $HOME/.config/broot/launcher/bash/br

# Source fzf
source $HOME/.config/fzf/zsh

# Make sure vim is the default editor
export EDITOR="$HOME/.nix-profile/bin/vim"
export VISUAL="$HOME/.nix-profile/bin/vim"

# Activate p10k
source $HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# Enable seamless isolated environments in every project dir with asdf-vm and asdf-direnv
[[ ! -f ${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc ]] ||  source ${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc
# Enable support for non-deterministic version numbers in .nvmrc for asdf
export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_available
# Install some npm packages by default with asdf nodejs
export ASDF_NPM_DEFAULT_PACKAGES_FILE=$HOME/.config/asdf-default-npm-packages

# ZSH syntax highlighting. This should be sourced last!
source $HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

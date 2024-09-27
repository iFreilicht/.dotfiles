# Setup fzf
# ---------
if [[ ! "$PATH" == *.nix-profile/share/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.nix-profile/share/fzf/bin"
fi

# Include dotfiles, except .git
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'

# Use top-to-bottom view, enable multimode and sensible keybindings
export FZF_DEFAULT_OPTS='
  --color=16
  --reverse --multi
  --bind tab:down --bind btab:up --bind ctrl-space:toggle
'

# Trigger autocomplete on *<TAB>
export FZF_COMPLETION_TRIGGER='*'

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.nix-profile/share/fzf/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.nix-profile/share/fzf/key-bindings.zsh"

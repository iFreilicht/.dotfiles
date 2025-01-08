{ lib, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;
  };

  programs.zsh.initExtraFirst = ''
    # Make sure instant prompt doesn't throw a warning if direnv hook is run on startup
    if [ $(command -v direnv) ]; then
      emulate zsh -c "$(direnv export zsh)"
    fi

    # Colourful output for a lot of additional utilities.
    # Needs to be sourced before instant prompt, otherwise it doesn't work
    [ -e "$HOME/.nix-profile/etc/grc.zsh" ] && source $HOME/.nix-profile/etc/grc.zsh
    unset -f ls || true # ls is also set by grc, but we color ls with grc on demand in our aliases

    # Enable Powerlevel8k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block; everything else may go below.
    if [[ -r "$${XDG_CACHE_HOME:-$$HOME/.cache}/p8k-instant-prompt-$${(%):-%n}.zsh" ]]; then
      source "$${XDG_CACHE_HOME:-$$HOME/.cache}/p8k-instant-prompt-$${(%):-%n}.zsh"
    fi
  '';

  programs.zsh.initExtra = lib.readFile ./zshrc;

  home.file = {
    ".config/zsh/.p10k.zsh".source = ./p10k.zsh;
    ".config/zsh/options.zsh".source = ./options.zsh;
    ".config/zsh/keybinds.zsh".source = ./keybinds.zsh;
    ".config/zsh/fzf.zsh".source = ./fzf.zsh;
  };
}

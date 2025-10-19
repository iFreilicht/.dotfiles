{ lib, config, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = true;
  };

  programs.zsh.initContent = lib.readFile ./zshrc;

  home.file = {
    ".config/zsh/.p10k.zsh".source = ./p10k.zsh;
    ".config/zsh/options.zsh".source = ./options.zsh;
    ".config/zsh/keybinds.zsh".source = ./keybinds.zsh;
    ".config/zsh/fzf.zsh".source = ./fzf.zsh;
  };
}

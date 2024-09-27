{ ... }:
{
  home.file = {
    ".config/kitty".source = ./kitty;
    ".config/ranger".source = ./ranger;
    ".config/thefuck".source = ./thefuck;
    ".config/zellij".source = ./zellij;
    ".config/asdf-default-npm-packages".source = ./asdf-default-npm-packages;
  };
}

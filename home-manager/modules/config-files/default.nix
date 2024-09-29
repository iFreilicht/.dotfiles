{ ... }:
{
  xdg.configFile = {
    "kitty/kitty.conf".source = ./kitty/kitty.conf;
    "ranger".source = ./ranger;
    "thefuck".source = ./thefuck;
    "zellij".source = ./zellij;
    "asdf-default-npm-packages".source = ./asdf-default-npm-packages;
  };
}

{ ... }:
{
  xdg.configFile = {
    "kitty/kitty.conf".source = ./kitty/kitty.conf;
    "ranger".source = ./ranger;
    "zellij".source = ./zellij;
    "asdf-default-npm-packages".source = ./asdf-default-npm-packages;
  };
}

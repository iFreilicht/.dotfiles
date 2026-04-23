{ config, ... }:
let
  symlink =
    name:
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home-manager/modules/config-files/${name}";
in
{
  xdg.configFile = {
    "kitty/kitty.conf".source = ./kitty/kitty.conf;
    "ranger".source = symlink "ranger"; # Ranger refuses to start if the config directory is not writeable
    "zellij".source = ./zellij;
    "asdf-default-npm-packages".source = ./asdf-default-npm-packages;
  };
}

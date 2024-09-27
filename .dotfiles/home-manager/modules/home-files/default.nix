{ ... }:
{
  home.file = {
    ".bashrc".source = ./bashrc;
    ".xprofile".source = ./xprofile;
    ".profile".source = ./profile;
  };
}

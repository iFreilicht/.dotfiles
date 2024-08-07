{ config, pkgs, lib, ... }:
{
  options = {
    felix = {
      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        example = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD..." ];
      };
    };
  };

  config = {
    users.users.felix = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user
        "samba" # Allow moving files to/from Samba shares
      ];
      openssh.authorizedKeys.keys = config.felix.authorizedKeys;
      packages = with pkgs; [ ];
      shell = pkgs.zsh;
    };
  };
}

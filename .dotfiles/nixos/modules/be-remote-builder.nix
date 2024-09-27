{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    uhl.beRemoteBuilder.authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = ''
        [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZ..."
        ]
      '';
    };
  };

  config = {
    # User account to run remote builds
    users.users.remote-build = {
      isSystemUser = true;
      hashedPassword = ""; # Only allow login via ssh
      openssh.authorizedKeys.keys = config.uhl.beRemoteBuilder.authorizedKeys;
      shell = pkgs.bash;
      group = "remote-build";
    };
    users.groups.remote-build = { };

    # Ensure both users can actually build derivations
    nix.settings = {
      trusted-users = [
        "felix"
        "remote-build"
      ];
    };

    # Ensure both users can actually build derivations
    nix.sshServe = {
      enable = true;
      # For now I don't need to have users that are allowed to access the store
      # but not allowed to trigger builds.
      keys = config.uhl.beRemoteBuilder.authorizedKeys;
    };
  };
}

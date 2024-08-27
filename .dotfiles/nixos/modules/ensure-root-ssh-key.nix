{ config, pkgs, lib, ... }: {
  options = {
    uhl.ensure-root-ssh-key.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Ensure that the root user has an ssh key. Generate one if necessary.";
    };
  };

  config = lib.mkIf config.uhl.ensure-root-ssh-key.enable {
    systemd.services.ensure-root-ssh-key = {
      enable = true;
      description = "Ensure that the root user has an ssh key. Generate one if necessary.";
      script = ''
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
        chown root:root /root/.ssh
        if [ ! -f /root/.ssh/id_ed25519 ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ""
        fi
      '';
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}

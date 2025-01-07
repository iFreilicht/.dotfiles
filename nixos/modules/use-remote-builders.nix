{
  config,
  net,
  lib,
  ...
}:
{
  imports = [
    ../modules/ensure-root-ssh-key.nix
  ];

  options = {
    uhl.useRemoteBuilders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Which remote builders in my network to use for building derivations.
      '';
    };
  };

  config = {
    nix =
      let
        mkBuildMachine = machine: {
          hostName = machine;
          sshUser = "remote-build";
          inherit (net.${machine}.remoteBuilder) system maxJobs speedFactor;
        };
      in
      {
        distributedBuilds = true;
        buildMachines = lib.map mkBuildMachine config.uhl.useRemoteBuilders;
      };

    programs.ssh.knownHosts = lib.genAttrs config.uhl.useRemoteBuilders (machine: {
      publicKey = net.${machine}.hostKey;
    });

    # Root user needs ssh key so nix-daemon can connect to remote builders
    uhl.ensureRootSshKey.enable = true;
  };
}

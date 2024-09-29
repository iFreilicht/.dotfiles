{
  # The flake the configuration is in
  self,
  # System-specific nixpkgs (i.e. pkgs.legacyPackages.${system})
  # This is the nixpkgs of the host running the rebuild command, not the target!
  pkgs,
  # Whether to use the --fast flag for nixos-rebuild. This will avoid rebuilding nix
  # before deployment, which is usually what you want
  fast ? true,
  # Extra arguments to pass to nixos-rebuild switch, boot, test, build, 
  extraBuildArgs ? [ ],
}:
let
  lib = pkgs.lib;
  nixos-rebuild = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
  hostname = "${pkgs.hostname}/bin/hostname";
  fastFlag = pkgs.lib.optionalString fast "--fast";

  allSystems = builtins.attrNames self.nixosConfigurations;

  helpFile = pkgs.writeText "flake-deploy-help.txt" ''
    Usage: nix run .#deploy.$name.$command [additional arguments]

    Replace `$name` with one of the available targets:
    - ${lib.concatStringsSep "\n- " allSystems}

    Replace `$command` with one of the available commands:
    - build: Just build the configuration, don't activate it
    - test: Switch to the new configuration temporarily. Will not add a new generation
    - boot: Build the configuration and make it the default so it gets enabled on reboot, not now
    - switch: Switch to the new configuration and make it the default
    - list-generations: List all generations of the configuration
    - install-on-blank-remote: Install NixOS on a remote machine that is currently booted into the installer. Uses nixos-anywhere
                               WARNING! This will format all drives if you're using disko! Be careful!
                               For this command to work, you have to pass a user@host argument, e.g. root@nixos

    Notes:
    You might have to use `path:.#` instead of `.#` if your flake is not using git.
    You might have to change `deploy` to the name of the attribute you gave it in your flake.
    Check `man nixos-rebuild` to see what additional arguments you can pass.
  '';
in
pkgs.writeShellScriptBin "flake-deploy" ''
  cat ${helpFile}
  exit 1
''
// (lib.pipe self.nixosConfigurations [
  (lib.mapAttrs (
    name: value:
    let
      flake = "--flake path:${self}#${name}";
      remoteDeploy = "--target-host ${name} --build-host ${name} --use-remote-sudo";
      writeBuildScript =
        action:
        pkgs.writeShellScriptBin "flakey-system_${action}" ''
          if [[ "$(${hostname})" == "${name}" ]]; then
            ${nixos-rebuild} ${action} ${flake} ${fastFlag} ${toString extraBuildArgs} "$@"
          else
            ${nixos-rebuild} ${action} ${flake} ${fastFlag} ${remoteDeploy} ${toString extraBuildArgs} "$@"
          fi
        '';
    in
    {
      build = writeBuildScript "build";
      test = writeBuildScript "test";
      boot = writeBuildScript "boot";
      switch = writeBuildScript "switch";
      list-generations = pkgs.writeShellScriptBin "flake-deploy_list-generations" ''
        if [[ "$(${hostname})" == "${name}" ]]; then
          ${nixos-rebuild} list-generations "$@"
        else
          # Use natively installed ssh so it interacts properly with keychains and agents
          ssh ${name} nixos-rebuild list-generations "$@"
        fi
      '';
      # Warning! I got this from my command history, but haven't tested it in this context yet!
      install-on-blank-remote = pkgs.writeShellScriptBin "flake-deploy_install-on-blank-remote" ''
        # Use nix run instead of adding nixos-anywhere as an input so it's only loaded when needed and always the latest version
        nix run github:nix-community/nixos-anywhere -- --build-on-remote ${flake} "$@"
      '';
    }
  ))
]

)

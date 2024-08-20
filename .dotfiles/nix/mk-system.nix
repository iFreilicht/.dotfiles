{
  # Hostname of the target machine
  name
, # The flake the configuration is in
  self
, # System-specific nixpkgs (i.e. pkgs.legacyPackages.${system})
  # This is the nixpkgs of the host running the rebuild command, not the target!
  pkgs
  # Whether to use the --fast flag for nixos-rebuild. This will avoid rebuilding nix
  # before deployment, which is usually what you want
, fast ? true
  # Extra arguments to pass to nixos-rebuild switch, boot, test, build, 
, extraBuildArgs ? [ ]
}:
let
  nixos-rebuild = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
  flake = "--flake path:${self}#${name}";
  fastFlag = pkgs.lib.optionalString fast "--fast";
  remoteDeploy = "--target-host ${name} --build-host ${name} --use-remote-sudo";

  writeBuildScript = action: pkgs.writeShellScriptBin "flakey-system_${action}" ''
    if [[ "$(${pkgs.hostname}/bin/hostname)" == "${name}" ]]; then
      ${nixos-rebuild} ${action} ${flake} ${fastFlag} ${toString extraBuildArgs} "$@"
    else
      ${nixos-rebuild} ${action} ${flake} ${fastFlag} ${remoteDeploy} ${toString extraBuildArgs} "$@"
    fi
  '';

in
{
  switch = writeBuildScript "switch";
  boot = writeBuildScript "boot";
  test = writeBuildScript "test";
  build = writeBuildScript "build";
  list-generations = pkgs.writeShellScriptBin "flakey-system_list-generations" ''
    if [[ "$(${pkgs.hostname}/bin/hostname)" == "${name}" ]]; then
      ${nixos-rebuild} list-generations "$@"
    else
      ssh ${name} nixos-rebuild list-generations "$@"
    fi
  '';
}

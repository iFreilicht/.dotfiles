{ pkgs, names }:

let
  lib = pkgs.lib;

  # Patch the wg-quick module from nixpkgs to return a `wg-quick-configs` config value
  originalWgQuick = "${pkgs.path}/nixos/modules/services/networking/wg-quick.nix";
  wgQuickPatched = pkgs.runCommandNoCC "wg-quick-patched" { } ''
    mkdir $out
    patch -o "$out/wg-quick.nix" ${originalWgQuick} ${./mk-wg-quick.patch}
  '';
  wgQuickPatchedModule = import "${wgQuickPatched}/wg-quick.nix";

  wireguard = import ../nixos/wireguard.nix;

  # Define a module that makes `wg-quick-configs` a valid config option
  wgQuickConfigsModule = {
    options.wg-quick-configs =
      with lib;
      mkOption {
        default = { };
        type = types.attrs;
      };
  };

  evaluateWgQuickModule =
    name:
    lib.evalModules {
      modules = [
        wgQuickConfigsModule
        wgQuickPatchedModule
        wireguard.${name}
      ];
      specialArgs = {
        inherit pkgs;
      };
    };

  # Evaluate modules in isolation so no full NixOS system is required
  evalOutput = lib.pipe names [
    (builtins.map (name: {
      inherit name;
      value = evaluateWgQuickModule name;
    }))
    lib.listToAttrs
    (lib.mapAttrs (name: value: value.config.wg-quick-configs))
  ];

in
# list all names
pkgs.writeText "wg-quick-configs" ''
  Use `nix build path:.#wireguard-configs.horse.wg0` to build the configuration for the `wg0` interface.
''
// evalOutput

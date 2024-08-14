{ pkgs, name }:

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
    options.wg-quick-configs = with lib; mkOption {
      default = { };
      type = types.attrs;
    };
  };

  # Evaluate modules in isolation so no full NixOS system is required
  evalOutput = lib.evalModules
    {
      modules = [
        wgQuickConfigsModule
        wgQuickPatchedModule
        wireguard.${name}
      ];
      specialArgs = { inherit pkgs; };
    };
in
evalOutput.config.wg-quick-configs

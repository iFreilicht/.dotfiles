{ inputs, ... }:

{
  nix.registry = {
    nixpkgs.flake = {
      inherit (inputs.nixpkgs) outPath;
    };
    stable.flake = {
      inherit (inputs.nixpkgs-stable) outPath;
    };
  };
}

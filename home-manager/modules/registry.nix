{ nixpkgs, nixpkgs-stable, ... }:

{
  nix.registry = {
    nixpkgs.flake = {
      inherit (nixpkgs) outPath;
    };
    stable.flake = {
      inherit (nixpkgs-stable) outPath;
    };
  };
}

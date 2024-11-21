{ pkgs, net, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit net;
      # Would be better to actually pass in pkgs-stable, but doesn't really matter on NixOS
      pkgs-stable = pkgs;
    };
    users.felix = import ./felix.nix;
  };
}

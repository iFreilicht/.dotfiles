{ pkgs, net, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    # Docs say useUserPackages has to be set to true, but
    # then some packages are only partially installed
    useUserPackages = false; 

    extraSpecialArgs = {
      inherit net;
      # Would be better to actually pass in pkgs-stable, but doesn't really matter on NixOS
      pkgs-stable = pkgs;
    };
    users.felix = import ./felix.nix;
  };
}

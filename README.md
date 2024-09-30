# iFreilicht's dotfiles

My dotfiles for my PCs and servers running NixOS and my MacBook.

## Installing

I use home-manager and nixos-rebuild with a custom wrapper and nh:

To deploy the server with the name `gateway` (maybe this could be integrated into nh?):

    nix run .#deploy.gateway.switch

To rebuild the local system configuration:

    nh os switch .

To update the dotfiles for the current user:

    nh home switch .

When setting up for the first time, run `nix shell nixpkgs#nh` first.

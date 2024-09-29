# iFreilicht's dotfiles

My dotfiles for my PCs and servers running NixOS and my MacBook.

## Installing

I use home-manager and nixos-rebuild with a custom wrapper.

To deploy the server with the name `gateway`:

    nix run .#deploy.gateway.switch

To rebuild the local configuration if you're on `source` (TODO: automatic inferrence based on hostname):

    sudo nix run .#deploy.source.switch

To update the dotfiles for the current user (no custom wrapper yet):

    home-manager --flake . switch

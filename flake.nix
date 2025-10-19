{
  description = "Default packages to install into user environment";

  inputs = {
    # `nix flake update` always upgrades nixpkgs to the latest version as well, which is annoying,
    # as I need to download nixpkgs again AND risk breakage. Lock the exact commit instead for both
    # stable and unstable. Stable is only required when unstable breaks (which happens often on darwin)
    # To upgrade, check https://hydra.nixos.org/jobset/nixpkgs/trunk
    # and select the latest commit hash that has no unfinished builds (meaning it's fully cached).
    # Use `git rev-parse 53a2c32` in a local nixpkgs checkout to find the full hash quickly.
    # Stable doesn't literally mean stable, it just means I can keep an older version of nixpkgs
    # around in case an update causes breakage, which happens somewhat frequently on macOS.
    nixpkgs.url = "github:NixOS/nixpkgs/5033f94f05a3539d4d7eabd96b0af5026cde5b0b";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/5033f94f05a3539d4d7eabd96b0af5026cde5b0b";

    flake-utils.url = "github:numtide/flake-utils";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      flake-utils,
      disko,
      home-manager,
      nix-darwin,
      sops-nix,
      ...
    }@inputs:
    let
      specialArgs = inputs // {
        net = import nixos/network.nix;
        wireguard = import nixos/wireguard.nix;
      };
    in
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-stable = nixpkgs-stable.legacyPackages.${system};
        mkWgQuickConfigs = import ./nix/mk-wg-quick-configs.nix;
        mkDeploy = import ./nix/mk-deploy.nix;
        extraSpecialArgs = specialArgs // {
          inherit pkgs-stable;
        };
      in
      {
        packages = {
          homeConfigurations = {
            "felix" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs extraSpecialArgs;
              modules = [ ./home-manager/felix.nix ];
            };

            # On my mac
            "feuh" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs extraSpecialArgs;
              modules = [ ./home-manager/feuh.nix ];
            };
          };

          deploy = mkDeploy { inherit self pkgs; };

          wg-quick-configs = mkWgQuickConfigs {
            inherit pkgs;
            names = [
              "horse"
              "DESKTOP-O2898M0"
              "source-win10"
            ];
          };
        };
      }
    ))
    // {
      darwinConfigurations = {
        horse = nix-darwin.lib.darwinSystem {
          modules = [ ./nix-darwin/horse/configuration.nix ];
        };
      };
      nixosConfigurations = {
        source = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./nixos/source/configuration.nix ];
        };

        junction = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = specialArgs // {
            mnt = import ./nixos/junction/mountpoints.nix;
          };
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            ./nixos/junction/configuration.nix
            ./home-manager/nixos-module.nix
            sops-nix.nixosModules.sops
          ];
        };

        gateway = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            home-manager.nixosModules.home-manager
            ./nixos/gateway/configuration.nix
            ./home-manager/nixos-module.nix
          ];
        };
      };
    };
}

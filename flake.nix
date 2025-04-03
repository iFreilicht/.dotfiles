{
  description = "Default packages to install into user environment";

  inputs = {
    flakey-profile.url = "github:lf-/flakey-profile";
    # `nix flake update` always upgrades nixpkgs to the latest version as well, which is annoying,
    # as I need to download nixpkgs again AND risk breakage. Lock the exact commit instead for both
    # stable and unstable. Stable is only required when unstable breaks (which happens often on darwin)
    # To upgrade, check https://hydra.nixos.org/jobset/nixpkgs/trunk for unstable
    # and https://hydra.nixos.org/jobset/nixpkgs/nixpkgs-23.11-darwin for stable
    # and select the latest commit hash that has no unfinished builds (meaning it's fully cached).
    # Use `git rev-parse 53a2c32` in a local nixpkgs checkout to find the full hash quickly.
    nixpkgs.url = "github:NixOS/nixpkgs/b9d43b3fe5152d1dc5783a2ba865b2a03388b741";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/3281bec7174f679eabf584591e75979a258d8c40";

    flake-utils.url = "github:numtide/flake-utils";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Only use tagged version of module. Should avoid compilation, but currently doesn't,
    # see https://git.lix.systems/lix-project/lix/issues/489
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        flakey-profile.follows = "flakey-profile";
      };
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
            ];
          };
        };
      }
    ))
    // {
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

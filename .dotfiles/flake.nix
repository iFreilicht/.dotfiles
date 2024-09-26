# To install these packages via nix, run:
#     nix run path:$HOME/.dotfiles#profile.switch

# I also recommend pinning the flakes registry and channels to avoid unnecessary downloads:
#     nix run path:$HOME/.dotfiles#profile.pin

# To use nix flake commands, you'll also have to refer to this flake by path (because of the bare repo, see README.md):
#     nix flake show path:$HOME/.dotfiles

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
    nixpkgs.url = "github:NixOS/nixpkgs/568bfef547c14ca438c56a0bece08b8bb2b71a9c";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/3281bec7174f679eabf584591e75979a258d8c40";

    flake-utils.url = "github:numtide/flake-utils";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };

    # Only use tagged version of module. Should avoid compilation, but currently doesn't,
    # see https://git.lix.systems/lix-project/lix/issues/489
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
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
      flakey-profile,
      nixpkgs,
      nixpkgs-stable,
      flake-utils,
      disko,
      sops-nix,
      ...
    }@inputs:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        pkgs-stable = nixpkgs-stable.legacyPackages.${system};
        mkWgQuickConfigs = import ./nix/mk-wg-quick-configs.nix;
        mkDeploy = import ./nix/mk-deploy.nix;
        vim = (import ./nix/vim.nix { inherit pkgs; });

        # This is a small hack to get the vimrc file into the profile so I can point vscode to it
        vimRc = pkgs.runCommandNoCC "custom-vimrc" { } ''
          mkdir -p $out/share/
          ln -s $(cat ${vim}/bin/vim | grep -oP "(?<=')[^']+(?=')") $out/share/custom-vimrc
        '';

        defaultPackages =
          (with pkgs-stable; [
            tlrc # Quick command help, tldr rust client. Command is tldr, not tlrc
          ])
          ++ (with pkgs; [
            # Basic terminal setup
            coreutils # Use consistent coreutils accross all platforms
            gnused # Use GNU sed on all platforms
            zsh-powerlevel10k # ZSH theme
            zsh-syntax-highlighting # Syntax highlighting when typing commands
            zsh-completions # Additional completions for ZSH
            direnv # Automatically switch environments in development folders
            grc # Colouring output of some default utilities
            autojump # Jump to often-visited directories quickly
            fzf # Fuzzy search command history
            zellij # Split views and sessions

            # Some utilities
            git-absorb # Easier fixup-rebase workflow for git
            bat # Colorized file output
            fd # Alternative to find, easier to use
            ripgrep # Alternative to grep, much quicker, uses regex by default
            jq # Formatting and querrying JSON strings
            moreutils # Additional useful utils. Especially sponge
            tree # Show directory tree
            pv # Monitor progress of piped data
            httpie # Modern curl alternative
            thefuck # Quickly correct common mistakes when typing commands
            imagemagick # Image processing
            btop # Richer resource monitor, alternative to htop
            ranger # Fast navigation through directory tree
            gnupg # PGP toolkit
            age # Encryption tool
            duf # Quick disk space view
            ncdu # Disk usage analyzer

            # Programming stuff
            asdf-vm # Version manager for all sorts of tools
            # Run `asdf plugin-add direnv` afterwards to enable integration with direnv
            # TODO: Enable direnv integration automatically
            gh # GitHub CLI
            sops # Store secrets safely in git repositories
            sqlfluff # SQL linter and formatter
            opentofu # IAC, open-source fork of Terraform

            # Nix stuff
            nh # Nix helper, very useful!
            nix-output-monitor # Much better view of build status
            nvd # Comprehensive difference between two derivations, especially helpful for profiles
            nixos-rebuild # Even on macOS and non-Nix linux for remote deployments
            nixfmt-rfc-style # Autoformatter for Nix
            nixpkgs-fmt # Another autoformatter, specific to nixpkgs
            nixd # Nix LSP language server

            # Containers
            docker # Container management CLI
            docker-compose # Container composition
            colima # Backend for Linux and macOS, which docker daemon isn't. Run `colima start`
            dive # Inspecting image contents without starting a container
          ])
          ++ [
            vim
            vimRc
          ];

        systemPackages =
          defaultPackages
          ++ lib.optionals (lib.strings.hasInfix "linux" system) (
            with pkgs;
            [
              # MacOS git supports unlocking with keychain, which is conventient
              git # Version management. Consistent version means access to new features on all platforms/distros.
              # Clipboard has a bug on Wayland, use custom fix from https://github.com/Slackadays/Clipboard/pull/203
              (clipboard-jh.overrideAttrs (oldAttrs: {
                version = "0.9.0.2+pre+fix_wayland_flicker";
                src = fetchFromGitHub {
                  owner = "iFreilicht";
                  repo = "Clipboard";
                  rev = "15bb982412e3134a09eab28d8c27d9a60f5f9aef";
                  hash = "sha256-g0YNnpqpGx17j4JzGVgDWanY0AqNtTfUffh9IKon0rc=";
                };
                buildInputs = oldAttrs.buildInputs ++ [ pkgs.openssl ];
              }))
            ]
          )
          ++ lib.lists.optionals (lib.strings.hasInfix "darwin" system) (
            with pkgs;
            [
              # The nix version somehow doesn't honor UTF-8 locales on linux, use the distro's version instead
              zsh
              clipboard-jh # Clipboard integration for X11, Wayland, macOS, Windows and OSC 52
            ]
          );
      in
      {
        packages = {
          profile =
            flakey-profile.lib.mkProfile {
              inherit pkgs;
              paths = systemPackages;
              pinned = {
                nixpkgs = toString nixpkgs;
                stable = toString nixpkgs-stable;
              };
            }
            // (
              let
                empty-profile = pkgs.runCommand "empty" { } "mkdir -p $out";
              in
              {
                history = pkgs.writeShellScriptBin "history" ''
                  # Workaround for https://github.com/NixOS/nix/issues/1807
                  ln -snf ${empty-profile} "$(dirname $(readlink ~/.nix-profile))/profile-0-link"
                  # Nix profile is not stable, this might break!
                  nix profile diff-closures
                '';
                list = pkgs.writeShellScriptBin "list" ''
                  ${pkgs.nvd}/bin/nvd list --root ~/.nix-profile
                '';
              }
            );

          deploy = mkDeploy { inherit self pkgs; };

          wg-quick-configs = mkWgQuickConfigs {
            inherit pkgs;
            names = [ "horse" ];
          };
        };
      }
    ))
    // (
      let
        specialArgs = inputs // {
          net = import nixos/network.nix;
          wireguard = import nixos/wireguard.nix;
        };
      in
      {
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
              ./nixos/junction/configuration.nix
              sops-nix.nixosModules.sops
            ];
          };

          gateway = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = [ ./nixos/gateway/configuration.nix ];
          };
        };
      }
    );
}

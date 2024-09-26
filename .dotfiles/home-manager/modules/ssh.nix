{
  config,
  pkgs,
  lib,
  net,
  ...
}:
{
  programs.ssh = {
    enable = true; # Only enable ssh configuration, but
    package = null; # use the system's ssh package

    matchBlocks =
      {
        "github.com" = {
          identityFile = "~/.ssh/id_ed25519";
          user = "git";
        };
        gateway = {
          hostname = net.gateway.wireguard.initialIP;
          user = "felix";
        };
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        # Use macOS keychain for ssh keys. This would fail on Linux or with nix-built ssh!
        "*" = {
          useKeychain = true;
          addKeysToAgent = true;
          identityFile = [
            "~/.ssh/id_ed25519"
            "~/.ssh/id_rsa"
          ];
        };
      }
      // lib.optionalAttrs (config.home.username != "felix") {
        source = {
          hostname = "source";
          user = "felix";
        };
        junction = {
          hostname = "junction";
          user = "felix";
        };
      };

    userKnownHostsFile = "~/.ssh/known_hosts ~/.ssh/hm_known_hosts";
  };

  home.file.".ssh/hm_known_hosts".text = ''
    # This file was created by home-manager
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    git.sr.ht ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60
    gitlab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf
  '';
}

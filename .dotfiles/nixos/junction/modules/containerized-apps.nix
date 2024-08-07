{ pkgs, net, ... }:
let
  pullImage = pkgs.dockerTools.pullImage;
in
{
  virtualisation.oci-containers.containers = {
    "snapdrop" = {
      image = "linuxserver/snapdrop";
      imageFile = pullImage {
        imageName = "linuxserver/snapdrop";
        finalImageTag = "version-debd13a0";
        imageDigest = "sha256:79f2c93ab4cdeb2e8c520d0a43a4d5ec9cc366eec189df65ea5866bfcc0e8e5c";
        sha256 = "sha256-8OLtduEkPBwG248iAQ7crj+QkG8NCksX4LYalH/bMYA=";
      };
      ports = [
        "${toString net.snapdrop.port}:80"
      ];
    };

    "kritzeln" = {
      image = "biosmarcel/scribble.rs";
      imageFile = pullImage {
        imageName = "biosmarcel/scribble.rs";
        finalImageTag = "v0.8.8";
        imageDigest = "sha256:28cccbbd4110117c1149a2cce6a0458ec8b381b64e18af2131ea224c8f5c2d82";
        sha256 = "sha256-NjR6fKh7uONWZ3leQd6dYGQhLtFXWjcFd+mhITKzVXg=";
      };
      ports = [
        "${toString net.kritzeln.port}:8080"
      ];
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    net.snapdrop.port
    net.kritzeln.port
  ];
}

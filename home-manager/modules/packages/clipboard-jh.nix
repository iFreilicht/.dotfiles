{ pkgs, ... }:
{
  # Clipboard integration for X11, Wayland, macOS, Windows and OSC 52
  # Used by my vim configuration to copy and paste to the system clipboard, even through ssh
  home.packages =
    if pkgs.stdenv.isLinux then
      [
        # Clipboard has a bug on Wayland, use custom fix from https://github.com/Slackadays/Clipboard/pull/203
        (pkgs.clipboard-jh.overrideAttrs (oldAttrs: {
          version = "0.9.0.2+pre+fix_wayland_flicker";
          src = pkgs.fetchFromGitHub {
            owner = "iFreilicht";
            repo = "Clipboard";
            rev = "15bb982412e3134a09eab28d8c27d9a60f5f9aef";
            hash = "sha256-g0YNnpqpGx17j4JzGVgDWanY0AqNtTfUffh9IKon0rc=";
          };
          buildInputs = oldAttrs.buildInputs ++ [ pkgs.openssl ];
        }))
      ]
    else
      [ pkgs.clipboard-jh ];
}

# To install these packages via nix, run
# nix-env -if tools.nix

# To update the packages, find the current latest release at https://status.nixos.org/,
# click the commit, and replace the full commit ID in the link below. Also, update the
# comment saying which version of nixpkgs this is and what the release date was

{
    # Unstable packages, the default
    # Search here: https://search.nixos.org/packages?channel=unstable
    pkgs ? import 
    (fetchTarball
      "https://github.com/NixOS/nixpkgs/archive/30d3d79b7d3607d56546dd2a6b49e156ba0ec634.tar.gz") # unstable on 2022-04-05
    { },
    # Stable packages, can be used as a fallback if unstable is broken
    # Search here: https://search.nixos.org/packages?channel=21.05
    stable ? import 
    (fetchTarball
      "https://github.com/NixOS/nixpkgs/archive/6120ac5cd201f6cb593d1b80e861be0342495be9.tar.gz") # 21.05 on 2021-09-20
    { }

}:

with pkgs; [
    # Basic terminal setup
    # zsh  # The nix version somehow doesn't honor UTF-8 locales, use the distro's version instead
    zsh-powerlevel10k  # ZSH theme
    direnv  # Automatically switch environments in development folders
    grc  # Colouring output of some default utilities
    autojump  # Jump to often-visited directories quickly
    fzf  # Fuzzy search command history

    # Some utilities
    bat  # Colorized file output
    fd  # Alternative to find, easier to use
    ripgrep  # Alternative to grep, much quicker, uses regex by default
    jq  # Formatting and querrying JSON strings

    # Programming stuff
    asdf-vm  # Version manager for all sorts of tools
    # Run `asdf plugin-add direnv` afterwards to enable integration with direnv
    # TODO: Enable direnv integration automatically

    # Containers
    docker  # Container management CLI
    colima  # Backend for Linux and macOS, which docker daemon isn't. Run `colima start`
]
++
(with stable; [
    vim
    vimPlugins.vim-plug  # Plugin manager. Version from unstable is broken as of 2021-09-20, see https://github.com/NixOS/nixpkgs/issues/138644
])

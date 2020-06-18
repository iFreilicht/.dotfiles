#!/usr/bin/env bash

# Install apt-installable stuff
apt_deps=(
    # Dependencies of polybar
    cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev
    libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev
    libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen
    xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev
    libiw-dev libcurl4-openssl-dev libpulse-dev
    libxcb-composite0-dev xcb libxcb-ewmh2
    libplayerctl2 playerctl # Media key support
    silversearcher-ag # ag (mainly for fzf)
    xininfo ffmpeg xclip maim slop copyq # Dependencies of teiler
    xdotool xsel # Dependencies of splatmoji
    nitrogen # Backgrounds
    tldr # Comprehensive man pages
    numlockx # Set numlock via console
    rofi # rofi task switcher / launcher
    neofetch # Show system info
    tree # Display directories as trees
    autojump # Jump to directories
    unrar # Previewing archives
    mediainfo # View info about media files
    fontforge # Font previews
    ffmpegthumbnailer # Video previews
    dex # Launching .desktop and autostart files
    jq # JSON processor, dependency of i3-focus-next.sh
)
sudo apt install -y $apt_deps
# Install python dependencies of ranger and ranger itself
py_deps=(
    dbus # dependency of polybar-spotify
    i3ipc # i3 wrapper for i3-alternating-layout
    chardet # Improved encoding detection for text files
    ueberzug # Very fast image previews
    ranger-fm
)
sudo python3 -m pip install $py_deps

# install polybar
cd .dotfiles/run/polybar && ./build.sh --all-features --auto; cd 

# install teiler from git repo
cd .dotfiles/run/teiler && sudo make install; cd

# Install all the vim stuff
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall && cd .vim/plugged/YouCompleteMe && ./install.py; cd
mkdir .vim/undodir # For persistent undo

# Install kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n

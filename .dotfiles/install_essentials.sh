# Jump to directories
sudo apt install -y autojump
# Display directories as trees
sudo apt install -y tree 
# Show system info
sudo apt install -y neofetch
# rofi task switcher / launcher
sudo apt install -y rofi
# Comprehensive man pages
sudo apt install -y tldr
# Dependencies of splatmoji
sudo apt install -y xdotool xsel
# Playerctl, for media keys
wget http://ftp.nl.debian.org/debian/pool/main/p/playerctl/libplayerctl2_2.0.1-1_amd64.deb \
&& wget http://ftp.nl.debian.org/debian/pool/main/p/playerctl/playerctl_2.0.1-1_amd64.deb \
&& sudo dpkg -i libplayerctl2_2.0.1-1_amd64.deb playerctl_2.0.1-1_amd64.deb
# Dependencies of teiler
sudo apt install -y xininfo ffmpeg xclip maim slop copyq
# install teiler from git repo
cd .dotfiles/run/teiler && sudo make install; cd

# Install dependencies of polybar
sudo apt install -y \
  cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
  libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev \
  libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen \
  xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev \
  libiw-dev libcurl4-openssl-dev libpulse-dev \
  libxcb-composite0-dev xcb libxcb-ewmh2
# install polybar
cd .dotfiles/run/polybar && ./build.sh --all-features --auto; cd 

# Install all the vim stuff
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall && cd .vim/plugged/YouCompleteMe && ./install.py; cd

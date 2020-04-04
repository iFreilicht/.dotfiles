
# Display directories as trees
sudo apt install tree 
# Show system info
sudo apt install neofetch
# rofi task switcher / launcher
sudo apt install rofi
# Dependencies of splatmoji
sudo apt install xdotool xsel
# Dependencies of teiler
sudo apt install xininfo ffmpeg xclip maim slop copyq
# install teiler from git repo
cd .dotfiles/run/teiler && sudo make install; cd

# Install dependencies of polybar
sudo apt install \
  cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
  libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev \
  libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen \
  xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev \
  libiw-dev libcurl4-openssl-dev libpulse-dev \
  libxcb-composite0-dev xcb libxcb-ewmh2
# install polybar
cd .dotfiles/run/polybar && ./build.sh --all-features --auto && \
  sudo make install
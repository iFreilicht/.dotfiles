#!/bin/bash

theme_dir=/usr/share/grub/themes/solarized

sudo mkdir -p $theme_dir

sudo cp ~/.dotfiles/grub/theme.txt $theme_dir/theme.txt
sudo cp ~/.dotfiles/images/grub_fanning.png $theme_dir/background.png

cp -an /etc/default/grub /etc/default/grub.bak
grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"$theme_dir/theme.txt\"" >> /etc/default/grub

sudo update-grub

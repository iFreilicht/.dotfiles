#!/bin/zsh
case $(hostname) in
    iFreilicht-LZ7)
        # Desktop, two screens
        xrandr --output DP-1 --primary --auto --output DVI-I-1  --auto --left-of DP-1
    ;;
    felix-XPS-12-Ubuntu)
        echo "On Laptop"
        # Laptop, two screens
        xrandr --output eDP-1 --auto --primary --output DP1 --auto --above eDP-1
    ;;
esac

#!/bin/zsh

# Failsafe
xrandr --auto

case $(hostname) in
    iFreilicht-LZ7)
        echo "On Desktop"
        # Desktop, three screens, daisy-chained
        xrandr --output DP-1-8 --auto --primary \
               --output DP-1-1-8 --auto --right-of DP-1-8 \
               --output DP-1-1-1 --auto --left-of DP-1-8 
    ;;
    felix-XPS-12-Ubuntu)
        echo "On Laptop"
        # Laptop, two screens
        xrandr --output eDP-1 --auto --primary --output DP1 --auto --above eDP-1
    ;;
    *)
        echo "On unknown machine"
    ;;
esac

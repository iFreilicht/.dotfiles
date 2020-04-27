#!/bin/zsh

# Reset all monitors
xrandr -s 0
# Failsafe 
xrandr --auto

case $(hostname) in
    source)
        echo "On host source"
        # Desktop, three screens, daisy-chained
        xrandr --output DP-1-8 --auto --primary \
               --output DP-1-1-8 --auto --right-of DP-1-8 \
               --output DP-1-1-1 --auto --left-of DP-1-8 
    ;;
    nomad)
        echo "On host nomad"
        # Laptop, two screens
        xrandr --output eDP-1 --auto --primary --output DP1 --auto --above eDP-1
    ;;
    *)
        echo "On unknown machine"
    ;;
esac

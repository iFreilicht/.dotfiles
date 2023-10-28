#!/bin/zsh

case $(hostname) in
    source)
        # Desktop, three screens, daisy-chained
        echo "On host source"

        # If nvidia driver is running
        if [ $(lshw -c video 2> /dev/null | grep -o 'nvidia') ]; then
            xrandr --output DP-0.8 --auto --primary \
                   --output DP-0.1.8 --auto --right-of DP-0.8 \
                   --output DP-0.1.1 --auto --left-of DP-0.8
        else
            # Default case for nouveau driver
            xrandr --output DP-1-8 --auto --primary \
                   --output DP-1-1-8 --auto --right-of DP-1-8 \
                   --output DP-1-1-1 --auto --left-of DP-1-8
        fi
    ;;
    nomad)
        echo "On host nomad"
        # Laptop, two screens
        xrandr --output eDP-1 --auto --primary --output DP1 --auto --above eDP-1
    ;;
    *)
        echo "On unknown machine"
        # Failsafe
        xrandr --auto
    ;;
esac

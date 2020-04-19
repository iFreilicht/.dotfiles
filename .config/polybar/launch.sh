#!/bin/bash

function log {
    bar=$1
    text=$2
    echo $text | tee -a "/tmp/polybar-$bar.log"
}

function open_bar {
    monitor=$1
    bar=$2
    
    log $bar "Opening $bar bar on monitor $monitor..."
    MONITOR=$monitor polybar -r $bar >>"/tmp/polybar-$bar.log" 2>&1 &
    # Sleep shortly to allow next bar to connect to i3
    sleep 1
}

log main "Killing old bars..." >> "/tmp/polybar.log"
# Terminate already running bar instances
killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 0.1; done
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Find primary and secondary monitors
primary=$(polybar --list-monitors | grep primary | cut -d ':' -f1)
others=$(polybar --list-monitors | grep -v primary | grep -v XRandR | cut -d ':' -f1)
log main "Found primary monitor: $primary"
log main "Found other monitors: $others"

# Launch bars
if [ -z $primary ]; then
    for monitor in $others; do
        open_bar $monitor unified
    done
elif [ -z $others ]; then
    open_bar $primary unified
else
    open_bar $primary primary
    for monitor in $others; do
        if [ $monitor = "DP-1-1-1" ]; then
            open_bar $monitor ternary
        else
            open_bar $monitor secondary
        fi
    done
fi

echo "Bars launched!"

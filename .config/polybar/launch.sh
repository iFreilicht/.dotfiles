#!/bin/bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Sleep shortly to allow bars to connect to i3
sleep 2

# Launch center and left bar
for bar in center left; do
    echo "---" | tee -a "/tmp/polybar-$bar.log"
    polybar -r $bar >>"/tmp/polybar-$bar.log" 2>&1 &
    # Sleep shortly to allow next bar to connect to i3
    sleep 1
done

echo "Bars launched..."
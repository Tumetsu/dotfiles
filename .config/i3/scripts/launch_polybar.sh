#!/usr/bin/env bash

# MONITOR1="$(xrandr --listmonitors | grep "0:" | cut -d ' ' -f6)"
# MONITOR2="$(xrandr --listmonitors | grep "1:" | cut -d ' ' -f6)"

# Terminate already running bar instances
sleep 3
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if [ -z "$POLYBAR_PRIMARY_MONITOR" ]; then
    export POLYBAR_PRIMARY_MONITOR=$(xrandr | grep primary | cut -d ' ' -f 1)
fi

# Launch bar1 and bar2
# $HOME/.config/i3/scripts/polybar -c $HOME/.config/i3/polybar_config default &
polybar -c $HOME/.config/i3/polybar_config default &

echo "Bars launched..."

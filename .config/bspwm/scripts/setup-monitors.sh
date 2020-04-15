#!/usr/bin/env bash

if [ -z "$PRIMARY_MONITOR" ]; then
    export PRIMARY_MONITOR=$(xrandr | grep primary | cut -d ' ' -f 1)
fi

outputs=$(xrandr --listactivemonitors|awk '{print $4}'|sed '/^$/d')

## set configurations per monitor
# bspc config -m 2 left_padding 0
# bspc config -m 2 bottom_padding 19

for monitor in $outputs; do
    if [[ ${m} == ${PRIMARY_MONITOR} ]]; then
        bspc monitor $monitor -d 1 2 3 4 5 6 7 8 9 10
    else
        bspc monitor $monitor -d 1 2 3 4 5 6 7 8 9 10
    fi
done

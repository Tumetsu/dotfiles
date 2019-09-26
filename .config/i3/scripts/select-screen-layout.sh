#!/usr/bin/env bash

CONFIG_TO_USE=()

for FILE in ~/.config/i3/screenlayout/*.sh; do
    tmpfile=$(echo ${FILE##*/}|sed 's/\.sh$//g')
    CONFIG_TO_USE+=("$tmpfile")
done

SETUP=$(printf '%s\n' "${CONFIG_TO_USE[@]}" \
    | dmenu -nb '#2f343f' -nf '#f3f4f5' -sb '#9575cd' -sf '#f3f4f5' -fn '-*-*-medium-r-normal-*-*-*-*-*-*-100-*-*' -i -p "Select screenlayout setup")

## set the screenlayout configuration from the script
## generated with arandr or xrandr
bash ~/.config/i3/screenlayout/${SETUP}.sh

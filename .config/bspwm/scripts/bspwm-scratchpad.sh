#!/usr/bin/env bash

if [ -z $1 ] || [ -z $2 ]; then
	echo "Usage: $0 <name of hidden scratchpad window> <window id>"
	exit 1
fi

CLASSNAME=$1
ID=$2

pids=$(xdotool search --class ${CLASSNAME})
for pid in $pids; do
	echo "Toggle $pid"
	bspc node $pid --flag hidden -f
done
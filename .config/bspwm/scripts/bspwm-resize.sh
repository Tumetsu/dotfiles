#!/usr/bin/env bash

# Extracted and adapted from source:
# https://github.com/Chrysostomus/bspwm-scripts/blob/master/bin/bspwm_resize.sh

# Resizes (expands or contracts) the selected node in the given
# direction.  This is assigned to a key binding in $HOME/.config/sxhkd/sxhkdrc

size=${2:-'10'}
direction=$1

case "$direction" in
    west)  bspc node @west  -r -"$size" || bspc node @east  -r -"$size" ;;
    south) bspc node @south -r +"$size" || bspc node @north -r +"$size" ;;
    north) bspc node @south -r -"$size" || bspc node @north -r -"$size" ;;
    east)  bspc node @west  -r +"$size" || bspc node @east  -r +"$size" ;;
esac

# if [ "$motion" = 'expand' ]; then
# 	# These expand the window's given side
# 	case "$direction" in
# 		north) bspc node -z top 0 -"$size" ;;
# 		east) bspc node -z right "$size" 0 ;;
# 		south) bspc node -z bottom 0 "$size" ;;
# 		west) bspc node -z left -"$size" 0 ;;
# 	esac
# else
# 	# These contract the window's given side
# 	case "$direction" in
# 		north) bspc node -z top 0 "$size" ;;
# 		east) bspc node -z right -"$size" 0 ;;
# 		south) bspc node -z bottom 0 -"$size" ;;
# 		west) bspc node -z left "$size" 0 ;;
# 	esac
# fi

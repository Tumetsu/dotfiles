#!/usr/bin/env bash

## detect layout automatically
autorandr -c

## Launch keybinding daemon
[[ ! $(pgrep -x sxhkd) ]] && sxhkd > /tmp/sxhkd.log &

## settings
syndaemon -i 1 -k -R -t
setxkbmap -model pc105 -layout ch -variant fr -option lv3:ralt_switch
localectl set-keymap fr_CH-latin1
xrdb -merge ~/.Xresources
/usr/bin/numlockx on
xset r rate 200 50
xhost +local:

## set default volume to 30%
#amixer -q sset Master 30%

## Caps Lock is Espace key
xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'

## set proper cursor
xsetroot -cursor_name left_ptr &

## pad gestures
libinput-gestures-setup start &

## set speed and other options for peripherals
~/.config/i3/scripts/xinput-config.sh &
##
## Applications
##

~/.config/polybar/launch-polybar.sh &
##feh --bg-scale ~/Pictures/wallpaper.jpg &
[ -f ~/.fehbg ] && ~/.fehbg &

nm-applet &
/opt/dropbox/dropboxd &
pulseaudio --start &
start-pulseaudio-x11
pulseaudio -k && pulseaudio -D
blueman-applet &
xfce4-power-manager &

[[ ! $(pgrep -x firefox) ]] && /usr/bin/firefox &
(tmux list-sessions|grep -Eo WORK) || termite -e "tmux new-session -A -s 'WORK'" &
## make vim and tmux look pretty
(termite -e "vim +qall!" ) &>/dev/null &

## run gnome keyring daemon
gome-keyring-daemon --start --daemonize --components=gpg,pkcs10,secrets,ssh &

## compozitor
picom -bcCGf -D 1 -I 0.05 -O 0.02 --no-fading-openclose --unredir-if-possible &

#!/usr/bin/env bash

_run() {
    if ! pgrep -x "$1" &>/dev/null ; then
        "$@" &
    fi
}

## detect layout automatically
autorandr -c

## Launch keybinding daemon
_run sxhkd > /tmp/sxhkd.log

## settings
# _run syndaemon -i 1 -k -R -t
setxkbmap -model pc105 -layout ch -variant fr -option lv3:ralt_switch
localectl set-keymap fr_CH-latin1
xrdb -merge ~/.Xresources
/usr/bin/numlockx on
xset r rate 200 70
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

##feh --bg-scale ~/Pictures/wallpaper.jpg &
[ -f ~/.fehbg ] && ~/.fehbg &

## start pulseaudio
pulseaudio --start
(ps -ef|grep -o "[p]ulseaudio -D") || pulseaudio -k; pulseaudio -D
start-pulseaudio-x11

## launch polybar after pulseaudio
~/.config/polybar/launch-polybar.sh &

## run applets
_run nm-applet
_run /opt/dropbox/dropboxd
_run blueman-applet
_run xfce4-power-manager

## always have a web browser
_run firefox

## start tmux session or join if present
(tmux list-sessions|grep -Eo WORK) || termite -e "tmux new-session -A -s 'WORK'" &
(termite -e "vim +qall!" ) &>/dev/null &

## run gnome keyring daemon
gome-keyring-daemon --start --daemonize --components=gpg,pkcs10,secrets,ssh &

## compozitor
_run picom -bcCGf -D 1 -I 0.05 -O 0.02 --no-fading-openclose --unredir-if-possible

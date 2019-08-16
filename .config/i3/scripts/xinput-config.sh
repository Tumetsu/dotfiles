#!/usr/bin/env bash

$exec xinput --set-prop "DLL06E4:01 06CB:7A13 Touchpad" "libinput Natural Scrolling Enabled" 0
$exec xinput --set-prop "DLL06E4:01 06CB:7A13 Touchpad" "libinput Click Method Enabled" 0 1
$exec xinput --set-prop "DLL06E4:01 06CB:7A13 Touchpad" 'libinput Accel Speed' 0.6
$exec xinput --set-prop "Logitech Perforance MX" "Device Accel Constant Deceleration" 0.700000
$exec xinput --set-prop "ZLY ZELOTES GAME MOUSE" "Device Accel Constant Deceleration" 0.700000
$exec xinput --set-prop "pointer:Logitech MX Master 2S" "libinput Accel Speed" 1.000000

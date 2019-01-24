#!/usr/bin/env bash
# dconf dump /org/gnome/terminal/legacy/profiles:/
# dconf reset -f /org/gnome/terminal/

dconf load /org/gnome/terminal/legacy/profiles:/:6ff18137-34d4-4517-8d4f-e19f58f60ea4/ < ./MonokaiBold.dconf
dconf load /org/gnome/terminal/legacy/profiles:/:e8d67329-f1b4-46e3-aee2-72fa2d07260b/ < ./Monokai.dconf

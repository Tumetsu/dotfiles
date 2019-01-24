#!/usr/bin/env bash

for DIR in $(ls $HOME/tools); do
    if test -d $DIR; then
        cd $DIR
        if test -d .git; then
            echo "[+] Running git pull in $DIR"
            git pull
        fi
    fi
    cd $HOME/tools
done

#!/usr/bin/env bash
#
# get color themes here : http://ciembor.github.io/4bit/
#
export_colors()
{
    gconftool-2 --dump '/apps/gnome-terminal' > /tmp/gnome-terminal-conf.xml
}

import_colors()
{
    # gconftool-2 --load gnome-terminal-conf.xml
    gconftool-2 --load "$1"
}

show_config()
{
    gconftool-2 -R '/apps/gnome-terminal'
}

if echo $1|egrep "import" ; then
    import_colors $2
fi

if echo $1|egrep "export";then
    export_colors
    echo "Terminal colors exported to /tmp/gnome-terminal-conf.xml"
fi
if echo $1|egrep "show";then
    show_config
fi

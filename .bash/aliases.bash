#!/usr/bin/env bash
#
# file: aliases.sh
#

##### The 'ls' family (this assumes you use a recent GNU ls)
##### or rust equivalent 'exa'
if command -v exa &>/dev/null; then
    alias ls='exa --color=auto --time-style=long-iso'
    alias ll='ls -l --color=auto'
    alias la='ls -la --color=always'
    alias llm='ls -l -s modified'
    alias llmr='ls -lr -s modified'
    alias llt='ll -T'
    alias llg='ll -G'
else
    alias ls='ls --color=always'
    alias sl='ls'
    alias la='ls -Al'          # show hidden files
    alias lx='ls -lXB'         # sort by extension
    alias lk='ls -lSr'         # sort by size, biggest last
    alias lc='ls -ltcr'        # sort by and show change time, most recent last
    alias lu='ls -ltur'        # sort by and show access time, most recent last
    alias lt='ls -ltr'         # sort by date, most recent last
    alias lm='ls -al|more'     # pipe through 'more'
    alias lr='ls -lR'          # recursive ls
    alias lsdirs="ls -l | grep --color=always '^d'"
fi

##### safety features
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'    # 'rm -i' prompts for every file
alias ln='ln -i'    # prompt whether to remove destinations
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

##### bash config shortcuts
alias br-conf='vim ~/.bashrc'
alias ba-conf='vim ~/.bash_aliases'
alias bp-conf='vim ~/.bash_aliases && source $_'
alias b-vmi='vim ~/.bash/init'
alias brc='source ~/.bashrc'

##### vim stuff
alias v='vim'
alias vi='vim -p'
alias vim='vim -p'
alias svi='sudo -E vim'
alias svim='sudo -E vim'
alias v-conf='vim ~/.vimrc'
alias va-conf='vim ~/.vim/autocmds.vim'
alias vc-conf='vim ~/.vim/config.vim'
alias vf-conf='vim ~/.vim/functions.vim'
alias vm-conf='vim ~/.vim/mappings.vim'
alias i-conf='vim ~/.config/i3/config'

##### tmux config shortcuts
alias tmux='tmux -2'
alias ta='tmux attach'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias tns='tmux new-session -s'
alias t-conf='vim ~/.tmux.conf'

##### directory changing shortcuts
alias ~='cd ~'
alias cd-='cd -'
alias cd..='cd ..'
alias cd...='cd ../../'
alias cd....='cd ../../../'
alias ..='cd ..'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'

###
### debian/ubuntu aliases
###

[[ "$(uname)" = "Linux" && $(command -v apt-get) ]] && {
alias a-search='apt search'
alias a-install='sudo apt install'
alias a-remove='sudo apt remove'
alias a-purge='sudo apt remove --purge'
alias a-update='sudo apt-get update && sudo apt-get upgrade && sudo apt-get autoremove && sudo apt-get autoclean'
alias a-upgrade='sudo apt update && sudo apt dist-upgrade && sudo apt autoremove'
alias a-show='sudo apt show'
alias a-info='sudo apt-cache showpkg'
alias a-deplist='apt-cache showpkg' # apt-cache rdepends works to
alias a-upgradeble="apt list --upgradeable"
alias dpkg-l='dpkg -l|grep --color=always'
alias dpkg-f='dpkg-query -L'
alias dpkg-stat='dpkg --status'
alias dpkg-extract='dpkg-deb --extract' # dpkg-deb --extract package.deb dir-to-extract-to
}

###
### Arch Linux
###

[[ "$(uname)" = "Linux" && $(command -v pacman) ]] && {
alias p-install='sudo pacman -S'
alias p-remove='sudo pacman -R'
alias p-update='sudo pacman -Syu'
alias p-search='pacman -Ss'
alias p-query-installed='pacman -Qs'
alias p-query-foreign='pacman -Qm'
alias p-list-aur-packages='pacman -Qm'
alias p-show='pacman -Si'
alias p-clean-cache='sudo pacman -Sc'
alias p-clean-orphans='sudo pacman -Rns $(pacman -Qtdq)'
alias p-list-orphans='pacman -Qtdq'
alias p-mirror-ranking='(curl -s \"https://www.archlinux.org/mirrorlist/?country=FR&country=GB&protocol=https&use_mirror_status=on\"|sed -e \"s/^#Server/Server/\" -e \"/^#/d\" | rankmirrors -n 5 -)>/tmp/pacman_mirrorlist'
## AUR aurman
alias pa-search='yay '
alias pa-install='yay -S'
alias pa-install-silent='yay -S --noconfirm'
alias pa-update='yay -Syu --topdown --cleanafter'
alias pa-remove='yay -R'
}

###
### RedHat/CentOS aliases
###

[[ -f /etc/redhat-release && $(command -v yum) ]] && {
alias y-search='yum search'
alias y-install='sudo yum install -y'
alias y-purge='sudo yum purge'
alias y-upgrade='sudo yum update'
alias y-info='yum info'
alias y-provides='yum provides'
alias y-deplist='yum deplist'
alias y-repos='yum repolist'
alias rpmqf='rpm -qf'
alias rpmV='rpm -V'
}

###
### Network related aliases
###

alias openports='netstat -nape --inet'
alias ports='netstat -lapute'
alias monittcp='sudo watch -n 1 "netstat -tpanl | grep ESTABLISHED"'
alias listening='sudo lsof -P -i -n'


###
### Services
###
alias show-enabled-services='sudo systemctl list-unit-files --state enabled'
alias show-running-services='sudo systemctl list-units --type service --state running'
alias show-active-services='systemctl -t service --state active'
alias show-running-services='systemctl -t service --state running'


###
### NVIDIA aliases
###
alias nvidia-on="sudo tee /proc/acpi/bbswitch <<<ON"
alias nvidia-off="sudo tee /proc/acpi/bbswitch <<<OFF"
alias nvidia-is-on="cat /proc/acpi/bbswitch"
alias nvidia-check64="optirun glxspheres64"
alias nvidia-check32="optirun glxspheres32"

###
### MISC
###

alias dfh='df -h'
alias grep='grep --color=always'
alias lesss="$(which less) -R"
alias more="$(which less) -R"
alias mkdir='mkdir -p'
alias meminfo='free -m -l -t'
alias cmount="mount | column -t"
alias 'ps?'='ps -ef | grep -Ei --color=always '
alias 'ps!'='ps -ef | grep -vEi --color=always '
alias xclip="xclip -selection c"
alias show_cpu_model='grep "model\|MHz" /proc/cpuinfo |tail -n 2'
alias busy='my_file=$(find /usr/include -type f | sort -R | head -n 1); my_len=$(wc -l $my_file | awk "{print $1}"); let "r = $RANDOM % $my_len" 2>/dev/null; vim +$r $my_file'
alias tree='tree -Csu'     # nice alternative to 'recursive ls'
alias show_options='shopt'
alias fix_stty='stty sane'
alias timestamp="date +%Y%m%d%H%M%S"

alias change-mouse-theme="sudo update-alternatives --config x-cursor-theme"
alias reload-xresources="xrdb ~/.Xresources"
alias show-xresources="xrdb -query -all"
alias show-wifi="wicd-curses" # wicd service should be started
alias disable-bluetooth="rfkill block bluetooth"
alias enable-bluetooth="rfkill unblock bluetooth"
alias xfreerdp="xfreerdp +clipboard /cert-ignore /size:1600x1024 /drive:home,/home/boogy/Commun "
alias polybar-restart="~/.config/i3/scripts/polybar-msg cmd restart"
alias kill-autolock="kill -9 $(pgrep xautolock)"
alias disable-hugepages="echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled"
alias cups-start="sudo systemctl start org.cups.cupsd.service"
alias cups-stop="sudo systemctl stop org.cups.cupsd.service"

## keyboard aliases
##
alias vt-console-keys-fix="sudo sh -c 'dumpkeys |grep -v cr_Console |loadkeys'"
alias keyboard-speed="xset r rate 200 50"
alias fr-keyboard="setxkbmap -model pc105 -layout ch -variant fr -option lv3:ralt_switch"
#alias sound-latency="pactl set-port-latency-offset $(pacmd list-sinks | egrep -o 'bluez_card[^>]*') headset-output 125000"


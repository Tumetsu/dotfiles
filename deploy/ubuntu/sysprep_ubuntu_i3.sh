#!/usr/bin/env bash
# https://faq.i3wm.org/question/3747/enabling-multimedia-keys/?answer=3759#post-id-3759
# https://github.com/acrisci/playerctl/releases
#
# Install font awesome to show icons on menu
#   https://github.com/FortAwesome/Font-Awesome/releases
#   http://fontawesome.io/cheatsheet/
#

##
## Shortcuts
##
## MOD+Shift+R -> reload i3
## MOD+Shift+Q -> kill/quit program
## MOD+d       -> run program (menu) dmenu_run

##
## File managers:
##   nautilus || thunar
##

if [[ "$(uname)" != "Linux"* ]]; then
  echo "$0 : Will only run on Linux debian/ubuntu"
  exit 1
fi

export mydirectory=~/tools
export DEBIAN_FRONTEND=noninteractive

### Install 32 bit libs also
sudo dpkg --add-architecture i386
sudo apt update
sudo apt upgrade -y
sudo apt -yq install libc6:i386 libc6-dev-i386 libncurses5:i386 libstdc++6:i386

##
## Ubunu PPAs
##
# sudo add-apt-repository -y ppa:jtaylor/keepass
sudo add-apt-repository -y ppa:libreoffice/ppa
sudo add-apt-repository -y ppa:webupd8team/java
sudo add-apt-repository -y ppa:ansible/ansible

sudo apt-get install software-properties-common apt-transport-https
sudo apt-get update
sudo apt-get upgrade -y

##
## Clean up
##
echo "[*] removal of default useless apps"
sudo apt remove -y --purge rhythmbox ekiga totem ubuntu-one unity-lens-music \
    unity-lens-photos unity-lens-video transmission transmission-gtk transmission-common \
    thunderbird apport gnome-mahjongg libgnome-games-support-common aisleriot gnome-sudoku

echo "[*] removal of search tools provided by unity"
sudo gsettings set com.canonical.Unity.Lenses disabled-scopes "['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope', 'more_suggestions-populartracks.scope', 'music-musicstore.scope', 'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']"
sudo gsettings set com.canonical.Unity.Lenses remote-content-search none

echo "[*] disable guest user and remote logon"
sudo sh -c 'printf "[SeatDefaults]\ngreeter-show-remote-login=false\n" >/usr/share/lightdm/lightdm.conf.d/50-no-remote-login.conf'
sudo sh -c 'printf "[SeatDefaults]\nallow-guest=false\n" >/usr/share/lightdm/lightdm.conf.d/50-no-guest.conf'


## Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce docker-compose
sudo usermod -aG docker ${USER}
sudo gpasswd -a $USER docker

echo "[*] installation of google-chrome stable amd64"
wget -nc https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb && rm -f $_

## SNAP installs
sudo systemctl start snapd.socket
sudo snap install keepassxc
sudo snap install remmina

## Install packages
sudo apt-get -y install \
    i3 i3-wm arandr feh rofi lxappearance ranger i3blocks pavucontrol wicd-curses j4-dmenu-desktop \
    compton xautolock volumeicon-alsa shutter evince evince-common keepass2 ghex vim-gtk \
    weechat weechat-curses weechat-scripts weechat-plugins proxychains tmux oracle-java8-installer \
    filezilla binwalk ipython ipython3 python3-pip virtualenvwrapper \
    apt-file git git-man nmap w3m w3m-img binutils foremost cntlm clusterssh curl wget gdb \
    gdb-multiarch gdbserver gnupg gnupg-agent gnupg2 htop netcat john-data build-essential \
    gcc gcc-multilib g++ openssh-client openssh-server corkscrew pssh openssl p7zip-full \
    ruby python-dev python-pip python3-dev python3-pip python3-cryptography python-docutils \
    python-markdown python-openssl python-qrtools python-pygments python-numpy python-lxml \
    python-virtualenv python-yara python-paramiko python-beautifulsoup python-pygresql \
    python-pil python-pycurl python-magic python-pyinotify python-configobj python-pexpect \
    python-msgpack python-requests python-pefile python-ipy python-pypcap python-dns python-dnspython \
    python-crypto python-cryptography python-nfqueue python-scapy python-capstone python-setuptools \
    python-urllib3 virtualenvwrapper rar unrar unzip strace ltrace ttf-dejavu ttf-dejavu-core \
    ttf-dejavu-extra yasm nasm zenity zenity-common imagemagick autojump \
    libimage-exiftool-perl freerdp-x11 reaver pyrit thc-ipv6 netwox nbtscan wireshark-qt \
    tshark vlan dsniff tcpdump openjdk-8-jre p7zip openvpn libwebkitgtk-1.0-0 libssl-dev \
    libmysqlclient-dev libjpeg-dev libnetfilter-queue-dev ettercap-text-only ghex pidgin pidgin-otr \
    traceroute lft gparted autopsy subversion ssh libpcap0.8-dev libimage-exiftool-perl proxychains \
    hydra hydra-gtk medusa irssi libtool rdesktop sshfs bzip2 extundelete rpcbind nfs-common \
    gimp iw ldap-utils ntfs-3g samba-common samba-common-bin steghide whois aircrack-ng openconnect gengetopt \
    byacc flex make cmake cmake-data automake ophcrack stunnel socat chromium-browser swftools hping3 tcpreplay tcpick gufw \
    secure-delete yersinia vmfs-tools qemu-kvm qemu-utils qemu-system* flashplugin-installer \
    autoconf libcapstone3 libcapstone-dev zlib1g-dev libxml2-dev libxslt1-dev libyaml-dev \
    libffi-dev libssh-dev libpq-dev libsqlite-dev libsqlite3-dev libpcap-dev libgmp3-dev \
    libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev \
    libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen xcb-proto libasound2-dev libmpdclient-dev \
    libpcre3-dev libidn11-dev libcurl4-openssl-dev network-manager-openconnect network-manager-pptp \
    network-manager-vpnc network-manager-vpnc-gnome network-manager-pptp-gnome libiw-dev \
    ansible xdotool wmctrl gnome-terminal gnome-system-monitor gnome-calendar \
    sslsplit nautilus nautilus-dropbox nautilus-share nautilus-wipe seahorse seahorse-nautilus \
    exfat-utils exfat-fuse cpulimit arc-theme gnome-themes-standard libcanberra-gtk-module \
    dconf-cli fonts-font-awesome libgtk-3-dev gtk2-engines-murrine

###
### Misc configs
###

## Make it look nice
mkdir -p ~/.icons && cp -r conf/icons/* ~/.icons/
## use the arc-theme package instead
## https://github.com/horst3180/arc-theme
# mkdir -p ~/.themes && cp -r conf/themes/* ~/.themes/

## visual studio code
mkdir -p ~/.config/Code/ && cp -r conf/VSCode/* ~/.config/Code/
mkdir -p ~/.vscode && mv ~/.config/Code/*.css ~/.vscode

## vlc config
mkdir -p ~/.config/vlc && cp conf/vlc/vlcrc ~/.config/vlc/

## Install monokai theme for the terminal
cd $mydirectory
git clone https://github.com/boogy/monokai-gnome-terminal && \
    cd monokai-gnome-terminal && \
    bash install.sh && \
    cd $mydirectory && \
    rm -rf monokai-gnome-terminal

## Install arc icon theme
## arc theme here: https://github.com/horst3180/arc-theme
cd $mydirectory
git clone https://github.com/horst3180/arc-icon-theme.git
cp -r arc-icon-theme/Arc ~/.icons/ && rm -rf arc-icon-theme


### Install python modules
# sudo pip2 install --upgrade pip
# sudo pip2 install --upgrade setuptools
pip2 install --upgrade --user r2pipe
pip2 install --upgrade --user isort
pip2 install --upgrade --user psutil
pip2 install --upgrade --user requests
pip2 install --upgrade --user pylint
pip2 install --upgrade --user pexpect
pip2 install --upgrade --user markdown
pip2 install --upgrade --user pycrypto
pip2 install --upgrade --user pwntools
pip2 install --upgrade --user xortool
pip2 install --upgrade --user scapy
pip2 install --upgrade --user ecdsa

### Install python3 modules
# sudo pip3 install --upgrade pip
# sudo pip3 install --upgrade setuptools
pip3 install --upgrade --user requests
pip3 install --upgrade --user pylint
pip3 install --upgrade --user pexpect-u
pip3 install --upgrade --user Pillow
pip3 install --upgrade --user numpy
pip3 install --upgrade --user pexpect
pip3 install --upgrade --user capstone
pip3 install --upgrade --user fierce
pip3 install --upgrade --user selectors


### Some must have cool tools
mkdir -p $mydirectory && cd $_
git clone https://github.com/longld/peda.git
git clone https://github.com/pwndbg/pwndbg.git
git clone https://github.com/mschwager/fierce.git
git clone https://github.com/darkoperator/dnsrecon.git


## Install radare2
cd $mydirectory
git clone https://github.com/radare/radare2
cd radare2 && sudo ./sys/install.sh


## Capstone for pwndbg
cd $mydirectory
git clone https://github.com/aquynh/capstone
cd capstone
git checkout -t origin/next
sudo ./make.sh install
cd bindings/python
sudo python3 setup.py install


## Replace ROPGadget with rp++
apt-get -yq install  cmake libboost-all-dev clang-3.5
export CC=/usr/bin/clang-3.5
export CXX=/usr/bin/clang++-3.5
cd $mydirectory
git clone https://github.com/0vercl0k/rp.git
cd rp
git checkout next
git submodule update --init --recursive
# little hack to make it compile
sed -i 's/find_package(Boost 1.59.0 COMPONENTS flyweight)/find_package(Boost)/g' CMakeLists.txt
mkdir build && cd build && cmake ../ && make && cp ../bin/rp-lin-x64 /usr/local/bin/


## Install ROPGadget
cd $mydirectory
git clone https://github.com/JonathanSalwan/ROPgadget \
    && cd ROPgadget \
    && python setup.py install


## Install Z3 Prover
# cd $mydirectory
# git clone https://github.com/Z3Prover/z3.git \
#     && cd z3 \
#     && python scripts/mk_make.py --python \
#     && cd build \
#     && sudo make install \


## Install binwalk
cd $mydirectory
git clone https://github.com/devttys0/binwalk
cd binwalk
python setup.py install
apt-get -yq install squashfs-tools


### CRACKING

echo "[*] install john the ripper magnumripper version"
cd $mydirectory
git clone https://github.com/magnumripper/JohnTheRipper.git
cd JohnTheRipper/src
./configure && make -sj8

### CRACKING END


echo "[*] install nikto"
cd $mydirectory
git clone https://github.com/sullo/nikto.git


echo "[*] install impacket"
cd $mydirectory
git clone https://github.com/CoreSecurity/impacket.git
cd $mydirectory
pip2 install . --user


echo "[*] install Responder"
cd $mydirectory
git clone https://github.com/SpiderLabs/Responder.git


## Install rust
## and ripgrep, exa
curl https://sh.rustup.rs -sSf | sh
cargo install ripgrep
cargo install exa

## Instal RVM for ruby
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
cd /tmp && \
    curl -sSL https://get.rvm.io -o rvm.sh && \
    cat /tmp/rvm.sh | bash -s stable
source $HOME/.rvm/scripts/rvm
RUBYVERSION=$(wget https://raw.githubusercontent.com/rapid7/metasploit-framework/master/.ruby-version -q -O - )
rvm install $RUBYVERSION --disable-binary
rvm use $RUBYVERSION --default --disable-binary


###
### Housekeeping
###
echo "[*] clean packages downloaded"
sudo apt autoclean -y
sudo apt autoremove -y
## this will install the requirements for chrome.
sudo apt -y install -f


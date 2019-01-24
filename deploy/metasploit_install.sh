#!/usr/bin/env bash
#
# Install metasploit framework (Debian/Ubuntu)
#
# Workaround for SUID problem with RVM ruby
# https://github.com/rvm/rvm/issues/2925
# rvm install ruby-2.5.1 --disable-binary
# THEN SET CAPABILITIES
# sudo setcap CAP_NET_BIND_SERVICE=+eip $HOME/.rvm/rubies/ruby-2.5.1/bin/ruby
#

## Install dependencies
echo "[+] Install dependencies"
sudo apt-get install build-essential libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev git-core autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev curl zlib1g-dev nmap

## Install the proper ruby version (RVM)
echo "[+] Install RVM"
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
source ~/.bashrc
echo "[+] Get metasploit-framework ruby version"
RUBYVERSION=$(wget https://raw.githubusercontent.com/rapid7/metasploit-framework/master/.ruby-version -q -O - )
rvm install $RUBYVERSION --disable-binary
rvm use $RUBYVERSION --default --disable-binary
echo "[+] Ruby version"
ruby -v

## Database configuration
## /opt/msf/config/database.yml
echo "[+] Create msf database"
sudo -s
su postgres
### create the database
createuser msf -P -S -R -D
createdb -O msf msf
exit
exit
echo "[+] Metasploit database configuration file"
echo "[+]   /opt/msf/config/database.yml"

## Install metasploit framework
echo "[+] Install metasploit-framework"
cd /opt
sudo git clone https://github.com/rapid7/metasploit-framework.git msf
sudo chown -R $(whoami) /opt/msf
cd msf

# If using RVM set the default gem set that is create when you navigate in to the folder
echo "[+] Set RVM gems for metasploit-framework"
rvm --default use ruby-${RUBYVERSION}@metasploit-framework
gem install bundler
bundle install

## If you want to link the commands to system PATH uncomment
read -p '[?] Create bin links in /usr/local/bin ? [Y/n]' do_msf_links
if echo $do_msf_links|grep -Eo "[yY]"; then
    sudo bash -c "for MSF in $(ls msf*); do ln -s /opt/metasploit-framework/$MSF /usr/local/bin/$MSF;done"
else
    echo "[+] Metasploit Framework installed in /opt/msf"
    echo "[+] Have fun ..."
fi


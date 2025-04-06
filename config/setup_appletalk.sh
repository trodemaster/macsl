#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# modern bash version check
! [ "${BASH_VERSINFO:-0}" -ge 4 ] && echo "This script requires bash v4 or later" && exit 1

# path to self and parent dir
SCRIPT=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPT)

# source the .env file
if [ -f "$SCRIPTPATH/.env" ]; then
  source "$SCRIPTPATH/.env"
else
  echo "No .env file found"
  exit 1
fi

# hackup hashicorp sources.list
sudo sed -i s/plucky/noble/g /etc/apt/sources.list.d/hashicorp.list

# load appletalk kernel module
sudo modprobe appletalk

# Load AppleTalk kernel module
if [ ! -f /etc/modules-load.d/appletalk.conf ] || ! grep -q appletalk /etc/modules-load.d/appletalk.conf; then
  echo "appletalk" | sudo tee /etc/modules-load.d/appletalk.conf
fi

# install needed packages
sudo apt update
sudo apt upgrade -y
sudo apt -y install golang libpcap-dev netatalk

# config netatalk
sudo systemctl stop netatalk || true
sudo systemctl stop atalkd || true

# Backup existing afp.conf if it exists
if [ -f /etc/netatalk/afp.conf ]; then
  sudo mv /etc/netatalk/afp.conf /etc/netatalk/afp.conf.bak
fi

# Create symlink to the afp config file
sudo ln -sf /Users/blake/config/afp.conf /etc/netatalk/afp.conf

# Backup existing atalkd.conf if it exists
if [ -f /etc/netatalk/atalkd.conf ]; then
  sudo mv /etc/netatalk/atalkd.conf /etc/netatalk/atalkd.conf.bak
fi

# Create symlink to the atalkd config file
sudo ln -sf /Users/blake/config/atalkd.conf /etc/netatalk/atalkd.conf

# backup existing netatalk service file
if [ -f /etc/systemd/system/netatalk.service ]; then
  sudo mv /etc/systemd/system/netatalk.service /etc/systemd/system/netatalk.service.bak
fi

# link to custom netatalk service file
sudo ln -sf /Users/blake/config/netatalk.service /etc/systemd/system/netatalk.service

# backup existing atalkd service file
if [ -f /etc/systemd/system/atalkd.service ]; then
  sudo mv /etc/systemd/system/atalkd.service /etc/systemd/system/atalkd.service.bak
fi

# link to custom atalkd service file
sudo ln -sf /Users/blake/config/atalkd.service /etc/systemd/system/atalkd.service

# set password for blake account
if ! [ -f /etc/netatalk/afppasswd ]; then
  sudo afppasswd -c
  sudo afppasswd -n -w $AFP_PASSWORD_BLAKE blake
fi

## install and configure jrouter
#go install drjosh.dev/jrouter@latest
#sudo setcap 'CAP_NET_BIND_SERVICE=ep CAP_NET_RAW=ep' ~/go/bin/jrouter
#
## install and configure jrouter.service file
#sudo ln -sf /Users/blake/config/jrouter.service /etc/systemd/system/jrouter.service

# reload systemd
sudo systemctl daemon-reload

# start services
sudo systemctl start atalkd
sudo systemctl enable atalkd
sudo systemctl start netatalk
sudo systemctl enable netatalk
# sudo systemctl start jrouter
# sudo systemctl enable jrouter

# update locate so I can find the files
sudo updatedb

exit 0
# try multiple nics on macpro? 
# Chooser crashing on phsical mac duo
# get OS9 lives images on scuzzy pi and boot from those.. 
# os 9 qemu can't see darkstar as it's on the same system.. 
# Same with seperate socket_vmnet or the same
# fix these and then add jrouter to the mix
# pull cube 12.ghz cpu and clean it
# get known good firmware and software on cube
# research crashing on 12.ghz cpu

sudo systemctl stop netatalk || true
sudo systemctl stop atalkd || true
sudo systemctl stop jrouter || true
sudo systemctl daemon-reload
sudo systemctl start atalkd
sudo systemctl start netatalk
sudo systemctl start jrouter

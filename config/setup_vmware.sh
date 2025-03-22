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

# install needed packages
sudo apt update
sudo apt upgrade -y
sudo apt -y install 
avahi-daemon avahi-utils libnss-mdns meson golang netatalk

# Load AppleTalk kernel module
sudo modprobe appletalk
echo "appletalk" | sudo tee /etc/modules-load.d/appletalk.conf

# config netatalk
sudo systemctl stop netatalk || true
sudo systemctl stop atalkd || true

# Backup existing afp.conf if it exists
if [ -f /usr/local/etc/afp.conf ]; then
  sudo mv /usr/local/etc/afp.conf /usr/local/etc/afp.conf.bak
fi

# Create symlink to the afp config file
sudo ln -sf /Users/blake/config/afp.conf /usr/local/etc/afp.conf

# Backup existing atalkd.conf if it exists
if [ -f /usr/local/etc/atalkd.conf ]; then
  sudo mv /usr/local/etc/atalkd.conf /usr/local/etc/atalkd.conf.bak
fi

# Create symlink to the atalkd config file
sudo ln -sf /Users/blake/config/atalkd.conf /usr/local/etc/atalkd.conf

# set password for blake account
if ! [ -f /usr/local/etc/afppasswd ]; then
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

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

sudo apt update
sudo apt -y install libpcap-dev golang netatalk

# config netatalk
sudo systemctl stop netatalk
sudo systemctl stop atalkd

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

# set password for blake account
sudo afppasswd -c
sudo afppasswd -n -w $AFP_PASSWORD_BLAKE blake

# install and configure jrouter
go install drjosh.dev/jrouter@latest
sudo setcap 'CAP_NET_BIND_SERVICE=ep CAP_NET_RAW=ep' ~/go/bin/jrouter

# install and configure jrouter.service file
sudo ln -sf /Users/blake/config/jrouter.service /etc/systemd/system/jrouter.service

# reload systemd
sudo systemctl daemon-reload

# start services
sudo systemctl start netatalk
sudo systemctl start atalkd
sudo systemctl enable jrouter
sudo systemctl start jrouter

# update locate so I can find the files
sudo updatedb

exit 0

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# modern bash version check
! [ "${BASH_VERSINFO:-0}" -ge 4 ] && echo "This script requires bash v4 or later" && exit 1

# path to self and parent dir
SCRIPT=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPT)

# configurable user paths
LINUX_USER_HOME="${LINUX_USER_HOME:-/home/$(whoami).linux}"
HOST_CONFIG_DIR="${HOST_CONFIG_DIR:-/Users/$(whoami)}"

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
sudo apt -y install golang libpcap-dev

# libkrb5-dev libavahi-client-dev bison flex \
#   libtalloc-dev libtracker-sparql-3.0-dev libcups2-dev libtirpc-dev quota \
#   libglib2.0-dev libcrack2-dev libwrap0-dev libiniparser-dev libevent-dev libgcrypt20-dev \
#   avahi-daemon avahi-utils libnss-mdns meson golang libdb5.3-dev \
#   libpcap-dev cmark libacl1-dev libldap2-dev libpam-dev cracklib-runtime libssl-dev \
#   tracker tracker-extract tracker-miner-fs \
#   systemtap-sdt-dev \
#   libreadline-dev \
#   mysql-client \
#   libelf-dev \
#   dbus-x11

# Load AppleTalk kernel module
#sudo modprobe appletalk
#echo "appletalk" | sudo tee /etc/modules-load.d/appletalk.conf

# netatalk
## Check if netatalk directory already exists
#if [[ ! -d ~/code/netatalk ]]; then
#  # Directory doesn't exist, clone the repo
#  echo "Cloning netatalk repository..."
#  git clone https://github.com/Netatalk/netatalk.git ~/code/netatalk
#else
#  echo "Netatalk repository already exists, skipping clone"
#fi

# Change to the netatalk directory regardless
#cd ~/code/netatalk
#
## configure the build
#meson setup --wipe build -Dwith-appletalk=true -Dwith-acls=true -Dwith-debug=false
#meson compile -C build
#sudo meson install -C build

# config netatalk
#sudo systemctl stop netatalk || true
#sudo systemctl stop atalkd || true

## Backup existing afp.conf if it exists
#if [ -f /usr/local/etc/afp.conf ]; then
#  sudo mv /usr/local/etc/afp.conf /usr/local/etc/afp.conf.bak
#fi
#
## Create symlink to the afp config file
#sudo ln -sf ${HOST_CONFIG_DIR}/config/afp.conf /usr/local/etc/afp.conf
#
## Backup existing atalkd.conf if it exists
#if [ -f /usr/local/etc/atalkd.conf ]; then
#  sudo mv /usr/local/etc/atalkd.conf /usr/local/etc/atalkd.conf.bak
#fi
#
## Create symlink to the atalkd config file
#sudo ln -sf ${HOST_CONFIG_DIR}/config/atalkd.conf /usr/local/etc/atalkd.conf
#
## set password for blake account
#if ! [ -f /usr/local/etc/afppasswd ]; then
#  sudo afppasswd -c
#  sudo afppasswd -n -w $AFP_PASSWORD_BLAKE blake
#fi

# install and configure jrouter
go install drjosh.dev/jrouter@latest
sudo setcap 'CAP_NET_BIND_SERVICE=ep CAP_NET_RAW=ep' ~/go/bin/jrouter

# install and configure jrouter.service file
sudo ln -sf ${HOST_CONFIG_DIR}/config/jrouter.service /etc/systemd/system/jrouter.service

# reload systemd
sudo systemctl daemon-reload

# start services
#sudo systemctl start atalkd
#sudo systemctl enable atalkd
#sudo systemctl start netatalk
#sudo systemctl enable netatalk
sudo systemctl start jrouter
sudo systemctl enable jrouter

# update locate so I can find the files
sudo updatedb

exit 0

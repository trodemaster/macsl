#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# modern bash version check
! [ "${BASH_VERSINFO:-0}" -ge 4 ] && echo "This script requires bash v4 or later" && exit 1

# path to self and parent dir
SCRIPT=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPT)

# Variables with default values
VAULT_ADDR="${VAULT_ADDR:-https://vault.example.com:8200}"
VAULT_AGENT_ROLEID="${VAULT_AGENT_ROLEID:-}"
VAULT_AGENT_SECRETID="${VAULT_AGENT_SECRETID:-}"
sudo sed -i s/plucky/noble/g /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt -y install libpcap-dev golang netatalk

# config netatalk
sudo systemctl stop netatalk

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

sudo systemctl daemon-reload
sudo systemctl start netatalk

# install and configure jrouter
# go install drjosh.dev/jrouter@latest

# update locate so I can find the files
sudo updatedb

exit 0

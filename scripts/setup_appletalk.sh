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
go install drjosh.dev/jrouter@latest


exit 0

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# modern bash version check
! [ "${BASH_VERSINFO:-0}" -ge 4 ] && echo "This script requires bash v4 or later" && exit 1

# path to self and parent dir
SCRIPT=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPT)
MACSL_ROOT=$(dirname $SCRIPTPATH)

# check for lima binary
if ! command -v limactl &> /dev/null
then
    echo "limactl could not be found"
    echo "Install lima from https://lima-vm.io/docs/installation/"
    exit 1
fi

# default VM name
VM_NAME="${1:-macsl}"
CONFIG_FILE="${MACSL_ROOT}/${VM_NAME}.yaml"

# validate config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file $CONFIG_FILE not found"
    exit 1
fi

echo "Building $VM_NAME VM..."

# update sha256 from web
echo "Fetching latest Ubuntu image hash..."
CURRENT_HASH=$(wget -qO- https://cloud-images.ubuntu.com/noble/current/SHA256SUMS | grep arm64.img | awk '{print $1}')

# update the digest in the yaml file
sed -i '' "s/digest: .*/digest: \"sha256:${CURRENT_HASH}\"/" "$CONFIG_FILE"

# if ~/.lima/${VM_NAME}/lima.yaml do a reset otherwise create a new instance
if [ -f ~/.lima/${VM_NAME}/lima.yaml ]; then
  echo "Resetting existing $VM_NAME VM..."
  limactl factory-reset $VM_NAME
  cp "$CONFIG_FILE" ~/.lima/${VM_NAME}/lima.yaml
else
  echo "Creating new $VM_NAME VM..."
  limactl create --name=$VM_NAME "$CONFIG_FILE" --tty=false
fi

# start the instance and build the image
echo "Starting $VM_NAME VM..."
limactl start $VM_NAME

# setting auto-start at login (only for main macsl VM)
if [ "$VM_NAME" = "macsl" ]; then
  limactl start-at-login $VM_NAME
fi

echo "$VM_NAME VM is ready!"
if [ "$VM_NAME" = "macsl" ]; then
  echo "Use 'make shell' to access the VM shell"
  echo "Use 'make logs' to view VM logs"
else
  echo "Use 'make test-shell' to access the VM shell"
fi

exit 0

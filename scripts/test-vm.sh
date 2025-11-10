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

echo "Creating macsl-test VM for development..."

# Create a test-specific YAML file with modified settings
TEST_YAML="${MACSL_ROOT}/macsl-test.yaml"
cp "${MACSL_ROOT}/macsl.yaml" "$TEST_YAML"

# Modify the test YAML to use different ports and names
# Change SSH port to avoid conflict
sed -i '' 's/localPort: 6666/localPort: 6667/' "$TEST_YAML"

# Change VM name in the message
sed -i '' 's/lima-{{.Name}}/lima-macsl-test/g' "$TEST_YAML"

# Use smaller resources for test VM
sed -i '' 's/cpus: 6/cpus: 4/' "$TEST_YAML"
sed -i '' 's/memory: 16GiB/memory: 8GiB/' "$TEST_YAML"
sed -i '' 's/disk: 100GiB/disk: 50GiB/' "$TEST_YAML"

# update sha256 from web
echo "Fetching latest Ubuntu image hash..."
CURRENT_HASH=$(wget -qO- https://cloud-images.ubuntu.com/noble/current/SHA256SUMS | grep arm64.img | awk '{print $1}')

# update the digest in the test yaml file
sed -i '' "s/digest: .*/digest: \"sha256:${CURRENT_HASH}\"/" "$TEST_YAML"

# check if test VM already exists
if limactl list | grep -q macsl-test; then
  echo "Removing existing macsl-test VM..."
  limactl stop macsl-test 2>/dev/null || true
  limactl delete macsl-test
fi

echo "Creating new macsl-test VM..."
limactl create --name=macsl-test "$TEST_YAML" --tty=false

# start the instance
echo "Starting macsl-test VM..."
limactl start macsl-test

# clean up the temporary test yaml
rm "$TEST_YAML"

echo "macsl-test VM is ready!"
echo "Use 'make test-shell' to access the test VM shell"
echo "Use 'make clean-test' to remove the test VM when done"
echo ""
echo "Note: This test VM uses different ports and resources to avoid"
echo "conflicting with your production macsl VM."

exit 0

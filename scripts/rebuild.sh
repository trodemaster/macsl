#!/opt/local/bin/bash

echo "Rebuilding macsl VM..."

# Check if the launchd_docker job is running
if launchctl list | grep -q "launchd_docker"; then
    echo "Stopping launchd_docker service..."
    launchctl bootout gui/$(id -u) ~/code/machine-cfg/$(hostname -s)/launchd_docker.plist
    echo "launchd_docker stopped."
fi

echo "Factory resetting macsl VM..."
limactl factory-reset macsl

echo "Copying latest configuration..."
cp ~/code/macsl/macsl.yaml ~/.lima/macsl/lima.yaml

echo "Starting macsl VM..."
limactl start macsl

echo "macsl VM rebuilt successfully!"
echo "Use 'make shell' to access the VM shell"

.PHONY: help build rebuild clean status logs shell

# Default target
help: ## Show this help message
	@echo "MacSL VM Management (Simplified)"
	@echo "Uses lima.yaml as the default configuration for the Lima VM"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build and start the Lima VM using lima.yaml
	@echo "Building Lima VM..."
	@if ! command -v limactl &> /dev/null; then \
		echo "Error: limactl not found. Install from https://lima-vm.io/docs/installation/"; \
		exit 1; \
	fi
	@echo "Fetching latest Ubuntu image hash..."
	@CURRENT_HASH=$$(wget -qO- https://cloud-images.ubuntu.com/noble/current/SHA256SUMS | grep arm64.img | awk '{print $$1}'); \
	sed -i '' "s/digest: .*/digest: \"sha256:$${CURRENT_HASH}\"/" lima.yaml
	@if [ -f ~/.lima/default/lima.yaml ]; then \
		echo "Resetting existing VM..."; \
		limactl factory-reset default; \
		cp lima.yaml ~/.lima/default/lima.yaml; \
	else \
		echo "Creating new VM..."; \
		limactl create --name=default lima.yaml --tty=false; \
	fi
	@echo "Starting VM..."
	limactl start default
	limactl start-at-login default
	@echo "Lima VM is ready!"
	@echo "Use 'make shell' or 'lima' to access the VM shell"
	@echo "Use 'make logs' to view VM logs"

rebuild: ## Factory reset and rebuild the Lima VM
	@echo "Rebuilding Lima VM..."
	@if launchctl list 2>/dev/null | grep -q "launchd_docker"; then \
		echo "Stopping launchd_docker service..."; \
		launchctl bootout gui/$$(id -u) ~/Developer/machine-cfg/$$(hostname -s)/launchd_docker.plist 2>/dev/null || true; \
		echo "launchd_docker stopped."; \
	fi
	@echo "Factory resetting VM..."
	limactl factory-reset default
	@echo "Copying latest configuration..."
	@cp lima.yaml ~/.lima/default/lima.yaml
	@echo "Starting VM..."
	limactl start default
	@echo "Lima VM rebuilt successfully!"
	@echo "Use 'make shell' or 'lima' to access the VM shell"

clean: ## Stop and remove the Lima VM
	@echo "Cleaning up Lima VM..."
	@if limactl list | grep -q default; then \
		limactl stop default 2>/dev/null || true; \
		limactl delete default; \
		echo "Lima VM removed"; \
	else \
		echo "Lima VM not found"; \
	fi

status: ## Show status of the Lima VM
	@echo "VM Status:"
	@echo "=========="
	@if limactl list | grep -q default; then \
		echo "Lima VM:"; \
		limactl list | grep default | head -1; \
	else \
		echo "Lima VM: Not found"; \
	fi

logs: ## Show logs for the Lima VM
	@if limactl list | grep -q default; then \
		limactl show-ssh default --format config | grep -E "(HostName|Port)" | head -1 | \
		awk '{print "ssh -p " $$2 " " $$1}' | sh -c 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $$0 "journalctl -f -u docker"'; \
	else \
		echo "Lima VM not running"; \
	fi

shell: ## Open shell in the Lima VM
	@if limactl list | grep -q default; then \
		limactl shell default; \
	else \
		echo "Lima VM not running. Run 'make build' first."; \
	fi

# Check for required dependencies
check-deps:
	@if ! command -v limactl &> /dev/null; then \
		echo "Error: limactl not found. Install from https://lima-vm.io/docs/installation/"; \
		exit 1; \
	fi
	@if ! command -v wget &> /dev/null; then \
		echo "Error: wget not found. Install wget."; \
		exit 1; \
	fi

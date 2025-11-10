.PHONY: help build build-test rebuild test-vm clean status logs shell

# Default target
help: ## Show this help message
	@echo "MacSL VM Management Makefile"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build and start the macsl VM with latest Ubuntu image
	@echo "Building macsl VM..."
	@./scripts/build.sh

build-test: ## Build and start the macsl-test VM with latest Ubuntu image
	@echo "Building macsl-test VM..."
	@./scripts/build.sh macsl-test

rebuild: ## Factory reset and rebuild the macsl VM
	@echo "Rebuilding macsl VM..."
	@./scripts/rebuild.sh

test-vm: ## Create and start a macsl-test VM for development (isolated from production)
	@echo "Creating macsl-test VM..."
	@./scripts/test-vm.sh

clean: ## Stop and remove the macsl VM
	@echo "Cleaning up macsl VM..."
	@if limactl list | grep -q macsl; then \
		limactl stop macsl 2>/dev/null || true; \
		limactl delete macsl; \
		echo "macsl VM removed"; \
	else \
		echo "macsl VM not found"; \
	fi

clean-test: ## Stop and remove the macsl-test VM
	@echo "Cleaning up macsl-test VM..."
	@if limactl list | grep -q macsl-test; then \
		limactl stop macsl-test 2>/dev/null || true; \
		limactl delete macsl-test; \
		echo "macsl-test VM removed"; \
	else \
		echo "macsl-test VM not found"; \
	fi

status: ## Show status of macsl and macsl-test VMs
	@echo "VM Status:"
	@echo "=========="
	@if limactl list | grep -q macsl; then \
		echo "macsl VM:"; \
		limactl list | grep macsl | head -1; \
	else \
		echo "macsl VM: Not found"; \
	fi
	@echo ""
	@if limactl list | grep -q macsl-test; then \
		echo "macsl-test VM:"; \
		limactl list | grep macsl-test; \
	else \
		echo "macsl-test VM: Not found"; \
	fi

logs: ## Show logs for the macsl VM
	@if limactl list | grep -q macsl; then \
		limactl show-ssh macsl --format config | grep -E "(HostName|Port)" | head -1 | \
		awk '{print "ssh -p " $$2 " " $$1}' | sh -c 'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $$0 "journalctl -f -u docker"'; \
	else \
		echo "macsl VM not running"; \
	fi

shell: ## Open shell in the macsl VM
	@if limactl list | grep -q macsl; then \
		limactl shell macsl; \
	else \
		echo "macsl VM not running. Run 'make build' first."; \
	fi

test-shell: ## Open shell in the macsl-test VM
	@if limactl list | grep -q macsl-test; then \
		limactl shell macsl-test; \
	else \
		echo "macsl-test VM not running. Run 'make test-vm' first."; \
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

# Internal targets for script execution
scripts/build.sh: build
scripts/rebuild.sh: rebuild
scripts/test-vm.sh: test-vm

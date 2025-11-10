# MacSL - Mac System Level Configuration

This repository contains configuration files and scripts for setting up AppleTalk networking services on Linux systems, particularly for legacy macOS compatibility.

## Overview

MacSL provides configuration files and setup scripts for Netatalk (AppleTalk protocol implementation) and related services to enable AppleTalk networking between modern Linux systems and legacy macOS computers.

## Components

### Netatalk Configuration
- `config/afp.conf` - AFP (Apple Filing Protocol) configuration
- `config/atalkd.conf` - AppleTalk daemon configuration
- `config/netatalk.service` - Systemd service file for Netatalk
- `config/atalkd.service` - Systemd service file for atalkd

### JRouter Configuration
- `config/jrouter.service` - Systemd service for JRouter
- `config/jrouter.yaml` - JRouter configuration file

### Setup Scripts
- `config/setup_appletalk.sh` - AppleTalk networking setup
- `config/setup_jrouter.sh` - JRouter setup
- `config/setup_vmware.sh` - VMware integration setup

## Quick Start

### VM Management (New Makefile-based workflow)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/macsl.git
   cd macsl
   ```

2. **Build and start the macsl VM:**
   ```bash
   make build
   ```

3. **Access the VM shell:**
   ```bash
   make shell
   ```

### Development Testing

For development work that won't interfere with your production VM:

```bash
# Create and start a separate test VM
make test-vm

# Access the test VM shell
make test-shell

# Check status of both VMs
make status

# Clean up test VM when done
make clean-test
```

### Legacy AppleTalk Setup (in VM)

Once inside the VM shell, run the AppleTalk setup:

```bash
sudo ./config/setup_appletalk.sh
sudo systemctl start netatalk
sudo systemctl start jrouter
```

## Docker Configuration

This repository previously contained Docker-based GitHub Actions runners, but these have been moved to the [blakeports](https://github.com/your-org/blakeports) repository under `docker/github-runners/` to consolidate all GitHub Actions runner functionality.

## Makefile Targets

The repository now uses a Makefile for VM management. Available targets:

```bash
make help          # Show help message
make build         # Build and start the macsl VM with latest Ubuntu image
make rebuild       # Factory reset and rebuild the macsl VM
make test-vm       # Create isolated macsl-test VM for development
make clean         # Stop and remove the macsl VM
make clean-test    # Stop and remove the macsl-test VM
make status        # Show status of both VMs
make shell         # Open shell in the macsl VM
make test-shell    # Open shell in the macsl-test VM
make logs          # Show logs for the macsl VM
```

### Test VM Features

The `make test-vm` target creates a separate development VM with:
- **Isolated environment**: Won't interfere with production macsl VM
- **Different SSH port** (6667 instead of 6666)
- **Reduced resources**: 4 CPUs, 8GB RAM, 50GB disk (vs 6 CPUs, 16GB RAM, 100GB disk)
- **Separate name**: `macsl-test` instead of `macsl`
- **Auto-cleanup**: Use `make clean-test` to remove when done

## File Structure

```
.
├── Makefile                       # VM management targets
├── scripts/                       # Build and management scripts
│   ├── build.sh                   # VM build script
│   ├── rebuild.sh                 # VM rebuild script
│   └── test-vm.sh                 # Test VM creation script
├── config/                        # Configuration files
│   ├── afp.conf                   # AFP configuration
│   ├── atalkd.conf                # AppleTalk daemon config
│   ├── netatalk.service           # Netatalk systemd service
│   ├── atalkd.service             # atalkd systemd service
│   ├── jrouter.service            # JRouter systemd service
│   ├── jrouter.yaml               # JRouter configuration
│   ├── setup_appletalk.sh         # AppleTalk setup script
│   ├── setup_jrouter.sh           # JRouter setup script
│   └── setup_vmware.sh            # VMware setup script
├── macsl.yaml                     # Main VM configuration file
└── README.md                      # This file
```

## Requirements

- Linux system with systemd
- Netatalk package
- Root/sudo access for service installation

## Installation

### Using the Setup Script

The easiest way to install is using the provided setup script:

```bash
sudo ./config/setup_appletalk.sh
```

This script will:
- Install required packages
- Copy configuration files
- Enable and start services
- Configure firewall rules

### Manual Installation

1. **Install Netatalk:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install netatalk

   # CentOS/RHEL
   sudo yum install netatalk
   ```

2. **Copy configuration files:**
   ```bash
   sudo cp config/afp.conf /etc/netatalk/
   sudo cp config/atalkd.conf /etc/netatalk/
   ```

3. **Install systemd services:**
   ```bash
   sudo cp config/netatalk.service /etc/systemd/system/
   sudo cp config/atalkd.service /etc/systemd/system/
   sudo systemctl daemon-reload
   ```

4. **Start services:**
   ```bash
   sudo systemctl enable netatalk
   sudo systemctl start netatalk
   ```

## Configuration

### AFP (Apple Filing Protocol)

Edit `/etc/netatalk/afp.conf` to configure file sharing:

```ini
[Global]
; Global server settings

[Homes]
; User home directories

[Shared]
; Shared directory
path = /path/to/shared/directory
```

### AppleTalk

The AppleTalk configuration in `/etc/netatalk/atalkd.conf` defines network settings:

```bash
# AppleTalk network configuration
eth0 -phase 2 -net 0-65534 -addr 65280.166
```

## Troubleshooting

### Check Service Status

```bash
sudo systemctl status netatalk
sudo systemctl status atalkd
```

### View Logs

```bash
journalctl -u netatalk -f
journalctl -u atalkd -f
```

### Network Testing

Test AppleTalk connectivity:

```bash
# List AppleTalk networks
nbplkup

# Test AFP connection
afp_client -l
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

See LICENSE file for details.

## Related Projects

- [blakeports](https://github.com/your-org/blakeports) - MacPorts development repository (contains moved GitHub Actions runners)
- [netatalk](https://github.com/Netatalk/netatalk) - Netatalk project repository
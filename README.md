# MacSL - Lima VM for macOS Development

MacSL provides a streamlined Lima-based Linux virtual machine setup optimized for hosting docker containers macOS

## Quick Start

1. **Clone and build:**
   ```bash
   git clone https://github.com/your-org/macsl.git
   cd macsl
   make build
   ```

2. **Access the VM:**
   ```bash
   make shell
   # Or use Lima's shorthand:
   lima
   ```

## Requirements

- **macOS** (Intel or Apple Silicon)
- **Lima** - Install via macports: `sudo port install lima`
- **wget** - For downloading VM images

## Available Commands

```bash
make help          # Show this help
make build         # Build and start the Lima VM using lima.yaml
make rebuild       # Factory reset and rebuild the Lima VM
make clean         # Stop and remove the Lima VM
make status        # Show status of the Lima VM
make logs          # Show logs for the Lima VM
make shell         # Open shell in the Lima VM
```

### Lima Shorthand Commands

Since MacSL uses Lima's default instance, you can also use Lima's built-in commands:

```bash
lima              # Open shell (same as 'make shell')
lima uname -a     # Run commands directly
limactl list      # List all instances
```

## VM Configuration

The VM is configured via `lima.yaml` and runs as Lima's default instance:

- **Ubuntu Questing** (development release, ARM64/x86_64)
- **Resources**: 8 CPUs, 16GB RAM, 100GB disk
- **SSH access** on port 6666
- **VM Type**: Apple Virtualization (VZ)
- **Network**: NAT with VZ networking
- **Automatic file sharing** with macOS host
- **Docker support** with rootful configuration
- **Development tools** via chezmoi dotfiles

### Key Features

- **Automatic image updates**: Always uses latest Ubuntu Questing ARM64/x86_64 images
- **Host integration**: Access host directories and Docker
- **Login auto-start**: VM starts automatically on login
- **Rosetta support**: Intel emulation on Apple Silicon
- **SSH key loading**: Automatic loading of SSH public keys

### Directory Mounts

- `~/code` - Development workspace
- `~/Downloads` - File sharing
- `~/scratch` - Temporary workspace

## Docker Setup

The VM includes automatic Docker installation with:

- **Rootful Docker** with socket forwarding to macOS
- **Host socket forwarding** for macOS Docker CLI access
- **Service management** with systemd

### Using Docker from macOS

After VM setup, the Lima startup message will show the exact commands to run. Copy and execute the Docker context commands from the message:

```bash
# Commands shown in VM startup (example):
docker context create lima --docker "host=unix:///Users/blake/.lima/default/sock/docker.sock"
docker context use lima
docker run --rm hello-world
```


## Customization

Edit `lima.yaml` to modify:

- VM resources (CPUs, memory, disk)
- Network settings and port forwards
- Additional mounts or services
- Container configurations

## Troubleshooting

### Check VM status
```bash
make status
limactl list
```

### View VM logs
```bash
make logs
```

### Reset VM completely
```bash
make rebuild
```

### Access VM directly
```bash
lima                    # Open shell
lima uname -a          # Run commands
limactl show-ssh       # Get SSH details
```

### Common Issues

- **Port conflicts**: Change SSH port in `lima.yaml` if 6666 is in use
- **Permission issues**: Ensure Lima has proper macOS permissions
- **Network issues**: Check Virtualization framework settings in macOS
- **VM not found**: Run `make build` to create the VM first

## File Structure

```
.
├── lima.yaml           # VM configuration (Lima format)
├── Makefile           # Build and management commands
├── LICENSE            # License information
└── README.md          # This documentation
```

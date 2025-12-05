# Lima Port Forwarding Configuration Guide

This guide covers the `portForwards` configuration in lima.yaml, focused on usage with **vzNAT** and **vz bridged** network interfaces.

## Overview

Lima supports automatic port forwarding from guest to host. When using vzNAT or bridged networks, you get a real IP address accessible from the host, but port forwarding rules still apply for controlling which ports are exposed and how.

### Network Context

| Network Type | Requirement | IP Access | Port Forwarding Role |
|--------------|-------------|-----------|---------------------|
| vzNAT | `vmType: vz`, macOS >= 13.0 | Direct IP from host | Controls localhost forwarding; direct IP bypasses rules |
| bridged | socket_vmnet + sudoers | Direct IP from network | Same as vzNAT |

With vzNAT/bridged, you can access guest services either:
1. **By IP address** - Direct access, port forwarding rules don't apply
2. **By localhost** - Port forwarding rules control access

## Configuration Options

### Basic Structure

```yaml
portForwards:
  - guestPort: 80
    hostPort: 8080
    hostIP: "127.0.0.1"
    guestIP: "127.0.0.1"
    proto: "tcp"
```

---

## hostIP

Controls which host interface the forwarded port binds to.

| Value | Description |
|-------|-------------|
| `127.0.0.1` | **(default)** Localhost only - accessible only from the Mac |
| `0.0.0.0` | All interfaces - accessible from other machines on the network |

### hostIP Examples

```yaml
portForwards:
  # Only accessible from localhost (default)
  - guestPort: 3000
    hostIP: "127.0.0.1"

  # Expose externally to the network
  - guestPort: 443
    hostIP: "0.0.0.0"

  # Bind to specific host interface
  - guestPort: 8080
    hostIP: "192.168.1.100"
```

### hostIP with Port Ranges

```yaml
portForwards:
  # Expose range externally
  - guestPortRange: [4000, 4999]
    hostIP: "0.0.0.0"
    hostPortRange: [4000, 4999]
```

---

## guestPortRange

Specifies which guest ports to forward. Accepts a two-element array `[start, end]`.

| Configuration | Behavior |
|---------------|----------|
| Not specified | Defaults to `[1, 65535]` (all ports) |
| `guestPort: N` | Equivalent to `guestPortRange: [N, N]` |
| `guestPortRange: [A, B]` | Forward ports A through B inclusive |

### Validation Rules

- Both values must be valid ports (1-65535)
- End port must be >= start port
- `hostPortRange` must specify the same number of ports as `guestPortRange`

### guestPortRange Examples

#### Single Port

```yaml
portForwards:
  # Forward single port
  - guestPort: 80
    hostPort: 8080

  # Equivalent using range syntax
  - guestPortRange: [80, 80]
    hostPortRange: [8080, 8080]
```

#### Port Range

```yaml
portForwards:
  # Forward a range of ports (1:1 mapping)
  - guestPortRange: [4000, 4999]
    hostPortRange: [4000, 4999]

  # Forward range to different host ports
  - guestPortRange: [3000, 3009]
    hostPortRange: [8000, 8009]
```

#### Multiple Specific Ports

```yaml
portForwards:
  # List individual ports as separate rules
  - guestPort: 80
    hostPort: 8080

  - guestPort: 443
    hostPort: 8443

  - guestPort: 3000
    hostPort: 3000

  - guestPort: 5432
    hostPort: 5432
```

#### Forward All Ports

```yaml
portForwards:
  # Explicit all-ports rule (this is the default behavior)
  - guestIP: "127.0.0.1"
    guestPortRange: [1, 65535]
    hostIP: "127.0.0.1"
    hostPortRange: [1, 65535]
```

---

## Complete Field Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `guestIP` | IP | `127.0.0.1` | Guest IP to match for forwarding |
| `guestPort` | int | - | Single guest port (shorthand for range) |
| `guestPortRange` | [int, int] | `[1, 65535]` | Range of guest ports to forward |
| `guestIPMustBeZero` | bool | false | When true, `0.0.0.0` matches only exact binding |
| `hostIP` | IP | `127.0.0.1` | Host interface to bind forwarded port |
| `hostPort` | int | same as guest | Single host port (shorthand for range) |
| `hostPortRange` | [int, int] | same as guest | Range of host ports |
| `proto` | string | `any` | Protocol: `tcp`, `udp`, or `any` |
| `ignore` | bool | false | When true, matching ports are NOT forwarded |
| `static` | bool | false | Persist across VM restarts in plain mode |

---

## Advanced Configuration

### guestIP and guestIPMustBeZero

Controls which guest bindings are matched for forwarding:

```yaml
portForwards:
  # Match only services bound to localhost (default)
  - guestIP: "127.0.0.1"
    guestPort: 8080

  # Match ANY interface (wildcard) - 0.0.0.0 matches 127.0.0.1, ::1, etc.
  - guestIP: "0.0.0.0"
    guestIPMustBeZero: false  # default
    guestPort: 7443
    hostIP: "0.0.0.0"

  # Match ONLY services explicitly bound to 0.0.0.0
  - guestIP: "0.0.0.0"
    guestIPMustBeZero: true
    guestPort: 7443
    hostIP: "0.0.0.0"
```

### Ignoring Ports

Exclude specific ports from forwarding:

```yaml
portForwards:
  # Don't forward anything bound to 0.0.0.0
  - guestIP: "0.0.0.0"
    proto: any
    ignore: true
    guestPortRange: [1, 65535]

  # But do forward localhost ports
  - guestIP: "127.0.0.1"
    proto: any
    hostIP: "127.0.0.1"
    guestPortRange: [1, 65535]
    hostPortRange: [1, 65535]
```

### Protocol Selection

```yaml
portForwards:
  # TCP only (SSH forwarder limitation)
  - guestPort: 22
    proto: "tcp"

  # UDP only (requires GRPC forwarder)
  - guestPort: 53
    proto: "udp"

  # Both TCP and UDP
  - guestPort: 5353
    proto: "any"
```

---

## Complete Examples

### Example 1: Web Development with vzNAT

```yaml
vmType: vz

networks:
  - vzNAT: true

portForwards:
  # Expose web server externally
  - guestPort: 80
    hostIP: "0.0.0.0"
    hostPort: 80

  # HTTPS
  - guestPort: 443
    hostIP: "0.0.0.0"
    hostPort: 443

  # Dev server range - localhost only
  - guestPortRange: [3000, 3010]
    hostIP: "127.0.0.1"
    hostPortRange: [3000, 3010]

  # Database - localhost only
  - guestPort: 5432
    hostIP: "127.0.0.1"
    hostPort: 5432
```

### Example 2: Multiple Services with Explicit Port List

```yaml
vmType: vz

networks:
  - vzNAT: true

portForwards:
  # Web server
  - guestPort: 80
    hostPort: 8080

  # API server
  - guestPort: 3000
    hostPort: 3000

  # PostgreSQL
  - guestPort: 5432
    hostPort: 5432

  # Redis
  - guestPort: 6379
    hostPort: 6379

  # MongoDB
  - guestPort: 27017
    hostPort: 27017
```

### Example 3: Port Range for Microservices

```yaml
vmType: vz

networks:
  - vzNAT: true

portForwards:
  # Reserve port range for microservices
  - guestPortRange: [8000, 8099]
    hostPortRange: [8000, 8099]
    hostIP: "127.0.0.1"

  # Expose load balancer externally
  - guestPort: 80
    hostPort: 80
    hostIP: "0.0.0.0"
```

### Example 4: Bridged Network with Selective Forwarding

```yaml
vmType: vz

networks:
  - lima: bridged

portForwards:
  # Don't forward external bindings
  - guestIP: "0.0.0.0"
    ignore: true
    guestPortRange: [1, 65535]

  # Forward specific localhost services
  - guestPort: 3000
    hostPort: 3000

  - guestPort: 8080
    hostPort: 8080

  # Forward a development port range
  - guestPortRange: [9000, 9009]
    hostPortRange: [9000, 9009]
```

### Example 5: Different Host and Guest Port Mappings

```yaml
vmType: vz

networks:
  - vzNAT: true

portForwards:
  # Remap privileged ports to unprivileged
  - guestPort: 80
    hostPort: 8080

  - guestPort: 443
    hostPort: 8443

  # Remap a port range
  - guestPortRange: [3000, 3004]
    hostPortRange: [13000, 13004]
```

---

## Rule Processing

Rules are processed **sequentially** - the first matching rule determines behavior:

```yaml
portForwards:
  # Rule 1: Ignore port 22 (checked first)
  - guestPort: 22
    ignore: true

  # Rule 2: Expose 80-443 externally (checked second)
  - guestPortRange: [80, 443]
    hostIP: "0.0.0.0"
    hostPortRange: [80, 443]

  # Rule 3: Forward remaining ports to localhost (fallback)
  - guestIP: "127.0.0.1"
    guestPortRange: [1, 65535]
    hostIP: "127.0.0.1"
    hostPortRange: [1, 65535]
```

Lima automatically appends a fallback rule that forwards all localhost ports 1-65535 if no explicit rule matches.

---

## Notes for vzNAT/Bridged Networks

1. **Direct IP Access**: With vzNAT or bridged networks, services in the guest are directly accessible by IP without port forwarding rules applying

2. **Performance**: vzNAT provides significantly better throughput (~59 Gbits/sec) compared to socket_vmnet shared (~3.5 Gbits/sec)

3. **Localhost Forwarding**: Port forwarding rules only affect access via `127.0.0.1` or the configured `hostIP`, not direct IP access

4. **Get Guest IP**:
   ```bash
   limactl shell <instance> ip addr show lima0
   ```

5. **Protocol Support**: SSH forwarder only supports TCP. For UDP, use GRPC forwarder:
   ```bash
   LIMA_SSH_PORT_FORWARDER=false limactl start
   ```

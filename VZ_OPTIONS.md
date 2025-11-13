# VZ Hypervisor Configuration Options

This document provides a comprehensive reference for all Lima YAML configuration options that are specific to the VZ (Virtualization.framework) hypervisor on macOS.

## Overview

The VZ driver uses Apple's Virtualization.framework to run Linux virtual machines on macOS. It requires macOS 13.0 or later and provides better performance and integration compared to QEMU.

## Core VZ Configuration

### vmType

**Required**: Set to `"vz"` to use the VZ hypervisor.

**Description**: Specifies the virtual machine type. Must be set to `"vz"` for VZ driver.

**YAML Example**:
```yaml
vmType: vz
```

### mountType

**Default**: `"virtiofs"`

**Description**: The mount type for shared directories. VZ supports `"virtiofs"` and `"reverse-sshfs"`. The `"9p"` mount type is not supported.

**YAML Example**:
```yaml
vmType: vz
mountType: virtiofs
```

## Rosetta Configuration

### vmOpts.vz.rosetta.enabled

**Type**: `boolean`

**Default**: `false`

**Description**: Enables Rosetta translation inside the VM. Rosetta allows running x86_64 binaries on Apple Silicon Macs. Requires `vmType: vz` and is only available on Apple Silicon Macs.

**Note**: If Rosetta gets stuck during installation, try running `softwareupdate --install-rosetta` on the host.

**YAML Example**:
```yaml
vmType: vz
vmOpts:
  vz:
    rosetta:
      enabled: true
```

### vmOpts.vz.rosetta.binfmt

**Type**: `boolean`

**Default**: `false`

**Description**: Registers Rosetta to `/proc/sys/fs/binfmt_misc` in the guest, allowing automatic execution of x86_64 binaries without explicit prefixing.

**Requirements**: Requires `vmOpts.vz.rosetta.enabled: true`

**YAML Example**:
```yaml
vmType: vz
vmOpts:
  vz:
    rosetta:
      enabled: true
      binfmt: true
```

## Audio Configuration

### audio.device

**Type**: `string`

**Default**: `""` (empty string)

**Valid Values for VZ**: `"vz"`, `"default"`, `"none"`

**Description**: Configures audio output for the VM. The VZ driver supports:
- `"vz"`: Uses Virtualization.framework audio
- `"default"`: Automatically selects the best available audio device
- `"none"`: Disables audio output

**YAML Example**:
```yaml
vmType: vz
audio:
  device: vz
```

## Video Configuration

### video.display

**Type**: `string`

**Default**: `"none"`

**Valid Values for VZ**: `"vz"`, `"default"`, `"none"`

**Description**: Configures video output for the VM. The VZ driver supports:
- `"vz"`: Uses Virtualization.framework graphics with GUI support
- `"default"`: Automatically selects the best available display
- `"none"`: Disables video output (headless mode)

**Note**: Setting to `"vz"` or `"default"` enables GUI support and allows running graphical applications.

**YAML Example**:
```yaml
vmType: vz
video:
  display: vz
```

## Network Configuration

### networks[].vzNAT

**Type**: `boolean`

**Default**: `null`

**Description**: Enables VZNAT network attachment using Virtualization.framework's NAT networking. This provides the VM with internet access without requiring root privileges or additional network setup.

**Requirements**: Only available with `vmType: vz`. Cannot be combined with `networks[].lima` or `networks[].socket` in the same network entry.

**YAML Example**:
```yaml
vmType: vz
networks:
- vzNAT: true
  # Optional: MAC address for consistent IP assignment
  macAddress: "52:55:00:00:00:01"
  # Optional: Interface name
  interface: lima0
  # Optional: Interface metric (lower = higher priority)
  metric: 100
```

**Advanced Example with Multiple Networks**:
```yaml
vmType: vz
networks:
- vzNAT: true
  interface: lima0
  metric: 100
- lima: shared
  interface: lima1
  metric: 200
```

## Firmware and Architecture

### arch

**Valid Values for VZ**: `"aarch64"`, `"x86_64"` (on Intel Macs)

**Description**: Architecture of the VM. VZ requires the architecture to match the host architecture.

**YAML Example**:
```yaml
vmType: vz
arch: aarch64  # On Apple Silicon
# or
arch: x86_64   # On Intel Macs
```

### firmware.legacyBIOS

**Ignored for VZ**: This setting is ignored by the VZ driver, which always uses UEFI.

**YAML Note**:
```yaml
vmType: vz
firmware:
  legacyBIOS: true  # This setting is ignored for VZ
```

### firmware.images

**Not Supported for VZ**: Custom UEFI firmware images are not supported by the VZ driver.

## Mount Configuration

### Mount Types Unsupported

**Default for VZ**: The VZ driver automatically sets appropriate mount type restrictions.

**Description**: The `"9p"` mount type is not supported with VZ. Use `"virtiofs"` or `"reverse-sshfs"` instead.

**YAML Example**:
```yaml
vmType: vz
mountType: virtiofs
mounts:
- location: "~"
  writable: false
- location: "/tmp"
  writable: true
```

## Additional Disks

### additionalDisks

**Type**: `[]Disk`

**Default**: `[]`

**Description**: Additional disks can be attached to VZ VMs. The VZ driver supports disk attachment through Virtualization.framework.

**YAML Example**:
```yaml
vmType: vz
additionalDisks:
- name: data
  format: true
  fsType: ext4
- name: backup
  format: false
```

## Validation Rules

### macOS Version Requirements

- **Minimum**: macOS 13.0 (Ventura)
- **Recommended for Intel**: macOS 15.5+ (for Linux kernel 6.12+ support)
- **Architecture**: Must match host architecture

### Unsupported Configurations

The following configurations are not supported or are ignored with VZ:

1. **Custom UEFI Images**: `firmware.images` is not supported
2. **Legacy BIOS**: `firmware.legacyBIOS` is ignored
3. **9P Mounts**: `mountType: "9p"` is not allowed
4. **Firmware Images**: Custom firmware images per VM type are ignored

### Required Settings

- `vmType` must be `"vz"`
- `arch` must match host architecture
- `mountType` cannot be `"9p"`

## Complete Example

Here's a complete example Lima YAML configuration using VZ with all major options:

```yaml
vmType: vz
arch: aarch64
mountType: virtiofs

vmOpts:
  vz:
    rosetta:
      enabled: true
      binfmt: true

audio:
  device: vz

video:
  display: vz

networks:
- vzNAT: true
  macAddress: "52:55:00:00:00:01"
  interface: lima0

mounts:
- location: "~"
  writable: false
- location: "/tmp"
  writable: true

additionalDisks:
- name: data
  format: true
  fsType: ext4

images:
- location: "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64.img"
  arch: aarch64
```

## Troubleshooting

### Common Issues

1. **"VZ driver requires macOS 13 or higher"**
   - Ensure you're running macOS 13.0 or later

2. **"Rosetta installation stuck"**
   - Run `softwareupdate --install-rosetta` on the host
   - Wait for Rosetta installation to complete

3. **"Unsupported mount type"**
   - Use `mountType: virtiofs` or `mountType: reverse-sshfs`
   - Remove `mountType: "9p"` configurations

4. **"Unsupported arch"**
   - Ensure `arch` matches your Mac's architecture
   - Apple Silicon: `aarch64`
   - Intel Macs: `x86_64`

5. **Network issues**
   - Use `vzNAT: true` for simple networking
   - Avoid combining `vzNAT` with `lima` or `socket` in the same network entry

### Performance Notes

- VZ provides better performance than QEMU on macOS
- Rosetta adds overhead for x86_64 binaries on Apple Silicon
- `virtiofs` generally provides better performance than `reverse-sshfs`
- GUI mode (`video.display: vz`) may impact performance

## References

- [Lima Documentation](https://lima-vm.io)
- [Virtualization.framework Documentation](https://developer.apple.com/documentation/virtualization)
- [Rosetta Documentation](https://developer.apple.com/documentation/apple-silicon/about-the-rosetta-translation-environment)

# The Embedded Device Map

## What does it actually map out?

The Embedded Device Map keeps track of:
- The device's ChipID (used in firmware security validation, such as in IMG3 and IMG4 files)
- The device's BoardID (also used in firmware security checks)
- The architecture of the device, and the relevant XNU targets.
- The SDK to use when building source code for the device, (SDKPlatform)
- The identifier of the device, such as iPhone9,1 (the iPhone 7)

See [Targets/Apple/T7001.json](Targets/Apple/T7001.json) for a quick reference on the format.

## Keys and Values

### Target

The name of the device target, so for the iPhone 7, that would be `D10AP`, the codename of the device alongside the `AP` marking, indicating a production device.

You can reference any of the non-Apple targets for a 'guide' on what a new Target value should be, but it's up to interpretation.

### TargetType

Usually this is the Target value, with the `AP` or `dev` trailer removed, alongside being in all lowercase, like how you see in Apple firmware payloads or in kernel compilation outputs.

The TargetType field has a maximum length of 8 characters as of XNU 6153.141.1, this was bumped to 16 characters in XNU 7195.50.7.100.1

### Platform

The Platform value usually indicates the specific SoC of the device, or alternatively, the name of the platform itself.

Whilst Apple sticks to their SoC names for the Platform, this value can be anything in the case of the Integrator CP target.

### ProductType

This is the Apple-like firmware identifier of the device, eg: iPhone9,1.

This value can be anything, as long as it adheres to the format.

### KernelMachOArchitecture

This is the architecture that should be used when building the kernel, which can be:
- armv6
- armv6k
- armv7
- armv7s
- armv7k
- arm64
- arm64e
- arm64_32

And likely others, such as armv5t, or armv4t.

### KernelPlatform

This boils down to which `MACHINE_CONFIGS` value the device should use when building XNU.

It also just so happens to be that this is the lowercase version.

### SDKPlatform

This indicates which SDK should be used to build source code for the device.

### ChipID

This value is the ID for the SoC of the device, or CPU parts, as seen with the Versatile and Integrator/CP targets.

### BoardID

This value is what differentiates boards from one another, usually used to match the correct firmware payloads together and ensure the security of the firmware.

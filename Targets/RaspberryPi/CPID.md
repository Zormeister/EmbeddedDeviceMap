# Raspi ChipIDs

These should follow the underlying CPU part names,

eg:
- BCM2835 SoCs use the ID 0x2708 to match the CPU block
- BCM2836 SoCs use the ID 0x2709 to match the CPU block
- BCM2837 SoCs use the ID 0x2710 to match the CPU block

These values also correspond to the IDs DarwinBoot asigns the SoCs, specifically [this file](https://github.com/Zormeister/DarwinBoot/blob/master/DarwinBoot/ARM/Machine/RPi/Data.c).

This isn't a problem for BCM2711 and BCM2711 devices.

One minor inconsistensy is that the ARM Integrator CP mapping uses the ID 0x1136, lacking a proper name for the CPU block, or series of digits.


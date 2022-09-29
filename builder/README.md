# Dynamically build conky sidebar configurations
## Design Overview
The goal is to be able to build a conky sidebar using *components* akin to building a lego with lego blocks.  
Each section of the sidebar can be thought of as a **block**.  These blocks can then be put together in order to build a conky sidebar.

Component examples:

- CPU and memory
- Network interface (wifi, ethernet)
- Disk
- Power/battery

![system differences](system-differences.png)

In the case of a pc, you will most likely have multiple disks to monitor.  While a laptop introduces power considerations (on battery, charging, plugged in).

## Challenges
1. If a block contains an image, the image's `y coordinate` would **change** depending where in the stack the particular block is placed.
2. The `vertical offset` of the last line or graph in a block must be consistent.  We want to be able to place a block anywhere in the sidebar stack and not have to worry about it's text/graph alignment shifting.
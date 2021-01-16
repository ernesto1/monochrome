# Monochrome Conky
A graphical conky interface to monitor your **fedora** system.  Available in two flavors:

### Laptop mode
Built for systems with small screen real state.  The desktop below is 1366 x 768 pixels.
![laptop](images/small-v04.png)

### Desktop mode
Built for systems with ample screen real state available.  The desktop below is 1920 x 1200 pixels.
![laptop](images/large-v04.png)

## Features
### DNF package lookup
DNF is periodically queried for new packages **if the system is iddle**.  
Slow machines will appreciate this, since a dnf package lookup may bring the cpu to a crawl.
### Network modes
Network devices reflect the current way you are connected to the internet
![network](images/network-modes.png)
### Power modes
![power](images/power-modes.png)

# How to install
## Dependencies
You only require to have `conky` installed on your system.

On **Fedora** install it by running:

```
sudo dnf install conky
```

**n.b.** I recommend using the conky package version `1.11.5_pre`.
More recent versions may have regressions that cause the theme to behave erratically.  Run the command `dnf downgrade conky` until you arrive at this version.

## How to run
1. Unzip the project's zip file in the folder `~/scripts/conky`
1. Rename the root folder `monochrome-master` to `monochrome`
1. Run the launch script `~/scripts/conky/monochrome/small/launch.bash`
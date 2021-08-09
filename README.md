# Monochrome Conky
A graphical conky interface to monitor your **fedora** system.  Available in two flavors:

### Laptop mode
Built for systems with small screen real state.  The desktop below is 1366 x 768 pixels.
![laptop](images/screenshots/1366x768.png)

### Desktop mode
Built for systems with ample screen real state available.

The desktop below is 1920 x 1200 pixels.  The code for this setup is available in the [v1.0 release](https://github.com/ernesto1/monochrome/releases/tag/v1.0).
![desktop 1920px](images/screenshots/1920x1200.png)

Setup for a 2560x1600 pixels desktop
![desktop 2560px](images/screenshots/2560x1600.png)

## Features
### DNF package lookup
DNF is periodically queried for new packages **if the system is iddle**.  
Slow machines will appreciate this, since a dnf package lookup may bring the cpu to a crawl.
### Network modes
Network devices reflect the current way you are connected to the internet.

Depending on your linux distribution, you may need to [configure the proper network device name](https://github.com/ernesto1/monochrome/wiki#network-devices).

![network](images/screenshots/network-modes.png)
### Power modes
![power](images/screenshots/power-modes.png)
### USB storage
USB devices are available for you to mix and match to the hardware you have.

These elements are considered **optional** and will only **appear** when the device is connected.
See the wiki entry for [how to configure these devices](https://github.com/ernesto1/monochrome/wiki#usb-drives) for your system.

![usb](images/screenshots/usbStorage.png)
# How to install
## Dependencies
You only require to have `conky` installed on your system.

On **Fedora** install it by running:

```
$ sudo dnf install conky
```

**n.b.** I recommend using the conky package version `1.11.5_pre`.
More recent versions may have regressions that cause the theme to behave erratically.  Run the command `dnf downgrade conky` until you arrive at this version.

## How to run
1) Unzip the project's zip file in the folder `~/conky`

```
$ unzip -d ~/conky monochrome-master.zip
```

2) Rename the root folder `monochrome-master` to `monochrome`

```
$ mv ~/conky/monochrome-master ~/conky/monochrome
```

3) Run the launch script of the mode you want:

Laptop mode

```
$ ~/conky/monochrome/launch.bash --laptop
```

or desktop mode

```
$ ~/conky/monochrome/launch.bash --desktop
```
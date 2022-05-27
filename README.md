# Monochrome Conky
A collection of graphical conky interfaces to monitor your system.

If you are new to conky, this [project's wiki page](https://github.com/ernesto1/monochrome/wiki) has  helpful guides to show you how to customize the conky configs to your system.

### Glass theme
![desktop 2560px](images/screenshots/glass.jpg)

### Compact theme
Conky reflects how your system is connected to the internet, wether it is through wifi or ethernet.  
Different states to show how your laptop is consuming power.

![compact](images/screenshots/compact.jpg)

### Widgets | small
Built for systems with small screen real state. The resolution below is 1366 x 768 pixels.  

![widgets small](images/screenshots/widgets-small.jpg)

### Widgets | large
Built for systems with ample screen real state available  
![desktop 2560px](images/screenshots/widgets-large.jpg)

## Features
### Repository package updates
`dnf` (the fedora package manager) is **periodically** queried for new packages if the system is **iddle**. Slow machines will appreciate this, since a dnf package lookup may bring the cpu to a crawl.

**n.b.** `dnf` is specific to **fedora** linux.  If you use a different distro, you will have to [update the script](https://github.com/ernesto1/monochrome/wiki) to use your distro's package manager.

### USB storage
USB devices are available for you to mix and match to the hardware you have.

These elements are considered **optional**.  Their state will change depending on whether the device is plugged in or not.
See the wiki entry for [how to configure these devices](https://github.com/ernesto1/monochrome/wiki#usb-drives) for your system.

![usb](images/screenshots/usbStorage.jpg)

# How to install
### Dependencies
You only require to have `conky` installed on your system.  
On **Fedora** install it by running:

```
$ sudo dnf install conky
```

**n.b.** I recommend using the conky package version `1.11.5_pre`  
more recent versions may have regressions/bugs ([issue 1](https://github.com/brndnmtthws/conky/issues/960), [issue 2](https://github.com/brndnmtthws/conky/issues/979)) that cause the theme to behave erratically.

Run the command `dnf downgrade conky` until you arrive at this version or download the RPM [from the web](https://rpm.pbone.net/info_idpl_70128821_distro_fedora32_com_conky-1.11.5-3.fc32.x86_64.rpm.html).

### Fonts
The small widgets [time conky](https://github.com/ernesto1/monochrome/blob/master/widgets-small/sidebar-time) requires the following fonts:

- [Promenade de la Croisette](https://www.fontspace.com/promenade-de-la-croisette-font-f23769)
- Noto Sans CJK JP Thin (default on fedora)

### Configuration
- The [wiki](https://github.com/ernesto1/monochrome/wiki) outlines items that may require configuration in order to customize this conky to your system, ex. device names such as network cards and hard drives
- If you run a multi monitor setup, you can read on how to configure conky to show on a [particular monitor](https://github.com/ernesto1/monochrome/wiki#multi-monitor-setups)

# How to run
1) Unzip the project's zip file in the folder `~/conky`

        $ unzip -d ~/conky monochrome-master.zip

2) Rename the root folder `monochrome-master` to `monochrome`

        $ mv ~/conky/monochrome-master ~/conky/monochrome

3) Run the launch script with the theme you want:

    - Glass

            $ ~/conky/monochrome/launch.bash --glass --layout-override desktop

    - Compact

            $ ~/conky/monochrome/launch.bash --compact

    - Widgets small

            $ ~/conky/monochrome/launch.bash --widgets-small --layout-override laptop

    - Widgets large

            $ ~/conky/monochrome/launch.bash --widgets-large

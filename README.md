# Monochrome Conky
A collection of graphical conky interfaces to monitor your system.

If you are new to conky, this [project's wiki page](https://github.com/ernesto1/monochrome/wiki) has  helpful guides to customize the conky configs to your system.

### Compact Dock
![compact](images/screenshots/compact.gif)

### Glass Dock
![desktop 2560px](images/screenshots/glass.jpg)

### Widgets | small
![widgets small](images/screenshots/widgets-small.jpg)

### Widgets | large
![desktop 2560px](images/screenshots/widgets-large.jpg)

# Scripts
These shell scripts were written two support this conky setup:

- A launcher script for executing multiple conky configs
- A new package update script

For more details on these scripts [see this wiki](https://github.com/ernesto1/monochrome/wiki/Scripts).

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
Time conkys use these fonts:

- [Promenade de la Croisette](https://www.fontspace.com/promenade-de-la-croisette-font-f23769)
- Noto Sans CJK JP Thin (default on fedora)

### Download the code for these conky scripts
Create the `~/conky` directory and clone this repository

       $ mkdir ~/conky
       $ cd ~/conky
       $ git clone https://github.com/ernesto1/monochrome.git

Alternatively you can download the latest `monochrome.zip` file form the releases page.

### Configuration
The [wiki](https://github.com/ernesto1/monochrome/wiki) outlines items that may require configuration in order to customize this conky to your system, ex. device names such as network cards and hard drives


# How to run
Run the launch script with the theme you want:

    - Glass

      $ ~/conky/monochrome/launch.bash --glass

    - Compact

      $ ~/conky/monochrome/launch.bash --compact

    - Widgets small

      $ ~/conky/monochrome/launch.bash --widgets-small

    - Widgets large

      $ ~/conky/monochrome/launch.bash --widgets-large

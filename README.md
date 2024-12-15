# Arch + Hyprland Dotfiles
## WARNING - INSTALLATION SCRIPT HAS BEEN TESTED AND CURRENTLY DOES NOT FULLY WORK, USE AT YOUR OWN RISK

## The System

> A full list of packages can be found in [`/bin/installscripts/packages/`](/bin/installscripts/packages).

### -- Key Features --
- Hyprland / SDDM / Waybar / Fuzzel
- Automatic BTRFS Backups Selectable from Grub Boot Menu
- Gruvbox Material theme (Theme Switcher Coming Soon)
- Multi-lingual Input
- Windows Compatibility Layers (Wine, Wine TTK, Bottles, Proton)
- FOSS First (Exceptions are opt-in on installation)
- Made for general multimedia, development, and gaming
- Guided installation


## Pre-Installation

### Boot the live environment
This installation guide assumes you have already completed the first several steps of the [Arch Installation guide](https://wiki.archlinux.org/title/Installation_guide), up to having [booted the live environment](https://wiki.archlinux.org/title/Installation_guide#Boot_the_live_environment).

### (OPTIONAL) Set the console font
> [!NOTE] The console is _not_ the terminal.  The console appears for logging in on boot.

Once in the live environment, feel free to set your console font using `setfont <font>` if you'd like.
If you'd like to see a full list of available fonts, you can run `ls /usr/share/kbd/consolefonts`.  Do not include the first dot or anything past it in the font name when using `setfont`.

### Connect to the internet
For the rest of the installation, an internet connection is needed to install packages.  Please follow the Arch Installation guide to [connect to the internet via Wi-Fi](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet) if you do not have an ethernet connection, which should work automatically.

### (OPTIONAL) Select Package Mirrors
> [!NOTE] This step is not required, but could speed up package installation on the system.

Instructions [here on the Arch Installation Guide](https://wiki.archlinux.org/title/Installation_guide#Select_the_mirrors).

### (TEMP) Pacman config
In `/etc/pacman.conf`, uncomment the "Include" line under `[multilib]`.  
Optionally uncomment the Include under `ParallelDownloads` towards the top to let Pacman install multiple packages at the same time. 

### For weather on the status bar - 
If you would like local weather information to appear on the status bar, you will need an OpenWeatherMap API key.  You will be asked to provide this during the main installation process, though it is not required.

Make an account on [OpenWeatherMap](https://openweathermap.org/) and get an API Key for One Call API 3.0.  Feel free to limit the calls per day to 1000 so that you do not get charged anything if you wish.

## Installation

Run `curl -L https://raw.githubusercontent.com/trevorbaughn/.dotfiles/refs/heads/master/bin/installscripts/sysinstall.sh > sysinstall.sh && chmod +x sysinstall.sh && ./sysinstall.sh` in the live environment.

This should kick off the main installation process.  Answer the prompts accordingly.  You will need to provide your new root password shortly after pacstrap installs the minimal required packages to kickoff the second part of the installation script after a reboot.

The main installation is complete once you reboot once more into the SDDM login screen.  Read on for necessary per-user manual configuration.

### Configure Hardware & Workspaces
Create `~/.config/hypr/hardware.conf`.  Configure monitors according to [the Hyprland Wiki](https://wiki.hyprland.org/Configuring/Monitors/). Next, create `~/.config/hypr/workspaces.conf` and make workspaces via [workspace rules](https://wiki.hyprland.org/Configuring/Workspace-Rules/).

## Extra Configuration

### Autostarting Applications
While you could simply throw auto-starting applications into `~/.config/hypr/hyprland.conf`, I throw them into `~/.config/hypr/autostart-extra.conf` instead if they're the sort of application I'm meant to be interacting with, rather than some daemon.  You'll need to make the file yourself - here's an example;
```
#######################
### AUTOSTART EXTRA ###
#######################

exec-once = kitty ~/bin/system-update.sh
exec-once = ~/Applications/WebCord-4.10.0-x64.AppImage
exec-once = flatpak run one.ablaze.floorp
```

If you don't want to use this file to autostart anything, then you must remove the source from SOURCES at the top of `~/.config/hypr/hyprland.conf`.

### Further Configuration
- [Hyprland Master Tutorial](https://wiki.hyprland.org/Getting-Started/Master-Tutorial/)*
- [Arch - Installation Guide](https://wiki.archlinux.org/title/Installation_guide)*
- [Arch - General Recommendations](https://wiki.archlinux.org/title/General_recommendations)**
- [Arch - Improving Performance](https://wiki.archlinux.org/title/Improving_performance)
- [Arch - Gaming](https://wiki.archlinux.org/title/Gaming)
- [Arch - Pro Audio](https://wiki.archlinux.org/title/Pro_Audio)
- [Arch - Network Configuration](https://wiki.archlinux.org/title/Network_configuration)

*Most settings are configured by the installation script.

**A reasonable amount of settings are configured by the installation script.

# TODO:

#### 1.0
- Theming
  - Gruvbox GTK & Kvantum Themes
  - Krita Kvantum overrides
  - Element Gruvbox
- Fix Japanese Keyboard
- Add Hotkeys
  - Open terminal in directory of current terminal
- Add CUPS start when necessary, and to waybar
- Additional Additions to Install Script/Settings
  - Make all proprietary software opt-in in install script
  - Simplify manual configuration
  - Check nvim w/Unity/Unreal?

#### 2.0
- Add Floorp Addons to installscript
- Add and configure TMUX
- Add accelerated video decoding
- Performance Mode Switcher
  - Pro Audio support w/JACK (semi-there)
- Modular Theme Switcher
  - Add Everforest?


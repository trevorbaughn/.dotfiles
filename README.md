# Arch + Hyprland Dotfiles

## Key Features
- English / Japanese Keyboard input
- Timeshift + Rsync Backups
- Everforest themes
  - ... Which are designed to be easy on the eyes!
- Hyprpaper (Wallpaper Daemon)
- Swaylock / Swayidle (Lock Screen)
- Waybar (Status Bar)
- wlogout (Shutdown GUI)
- Mako (Notification Daemon)
- Wofi (Application Launcher)
- Hyprshot (Screenshot Tool)
- Wine, Bottles, Proton (Compatibility Layers)

| -- Additional Tools -- |
| --- | --- |
| - Kitty | (Terminal Emulator) |
| - Evolution | (Mail/Calendar/Contacts) |
| - Floorp | (Web Browser) |
- Neovim w/LazyVim (IDE)
- Unity3D, Unreal Engine 5, Godot (Game Engines)
- Krita, GIMP, Inkscape (Art)
- OBS Studio (Recording)
- Davinci Resolve (Video Editing)
- LMMS (Digital Audio Workstation)
- Audacity (Light Audio Editing)
- Obsidian (Notes)
- VLC (Media Player)
- Darktable (Photo Editing)
- ImageLounge (Image Viewer)
- Steam, Lutris (Gaming)
- Webcord, Element, Slack, Zoom (Message Clients)

A full list of packages can be found in [`/bin/installscripts/packages/`](/bin/installscripts/packages).

## Pre-Installation

### Boot the live environment
This installation guide assumes you have already completed the first several steps of the [Arch Installation guide](https://wiki.archlinux.org/title/Installation_guide), up to having [booted the live environment](https://wiki.archlinux.org/title/Installation_guide#Boot_the_live_environment).

### (OPTIONAL) Set the console font
Once in the live environment, feel free to set your console font using `setfont <font>` if you'd like.
If you'd like to see a full list of available fonts, you can run `ls /usr/share/kbd/consolefonts`.  Do not include the first dot or anything past it in the font name when using `setfont`.
> [!NOTE] The console is _not_ the terminal.  The console appears for logging in on boot.

### Connect to the internet
For the rest of the installation, an internet connection is needed to install packages.  Please follow the Arch Installation guide to [connect to the internet via Wi-Fi](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet) if you do not have an ethernet connection, which should work automatically.


## Installation
To install these dotfiles should be mostly as simple as cloning this repository into your Home directory and running the yet-to-be-documented-or-tested install scripts under `~/bin/installscripts/`.

### ~/bin/installscripts/sysinstall.sh
Run `chmod +x ~/bin/installscripts/sysinstall.sh` followed by `~/bin/installscripts/sysinstall.sh`.  This should kick off the main installation script, which may take a while.

### Configure Hardware & Workspaces
Create `~/.config/hypr/hardware.conf`.  Configure monitors according to [the Hyprland Wiki](https://wiki.hyprland.org/Configuring/Monitors/). Next, create `~/.config/hypr/workspaces.conf` and make workspaces via [workspace rules](https://wiki.hyprland.org/Configuring/Workspace-Rules/).  If not using AMD, adjust the HARDWARE section of `~/.bashrc` accordingly.

### (OPTIONAL) For weather on the status bar - 
Make an account on [OpenWeatherMap](https://openweathermap.org/) and get an API Key for One Call API 3.0.  Feel free to limit the calls per day to 1000 so that you do not get charged anything if you wish.

Create `~/.config/waybar/modules/weather/weather_conf.py` and fill in the following;
```
# OpenWeatherMap API and City ID
city_id = <7-digit city ID on OpenWeatherMap>
api_key = "<API Key from OpenWeatherMap>"
```
Once saved, run `chmod a+x ~/.config/waybar/modules/weather/weather_conf.py` to finish enabling weather on the status bar.

## Extra Configuration

### Autostarting Applications
While you could simply throw auto-starting applications into `~/.config/hypr/hyprland.conf`, I throw them into `~/.config/hypr/autostart-extra.conf` instead if they're the sort of application I'm meant to be interacting with, rather than some daemon.  You'll need to make the file yourself - here's an example;
```
#######################
### AUTOSTART EXTRA ###
#######################

exec-once = $Terminal
exec-once = ~/Applications/WebCord-4.10.0-x64.AppImage
exec-once = flatpak run one.ablaze.floorp
```

If you don't want to use this file, then you must remove the source from SOURCES at the top of `~/.config/hypr/hyprland.conf`.

### Further Configuration
- [Hyprland Master Tutorial](https://wiki.hyprland.org/Getting-Started/Master-Tutorial/)*
- [Arch - Installation Guide](https://wiki.archlinux.org/title/Installation_guide)*
- [Arch - General Recommendations](https://wiki.archlinux.org/title/General_recommendations)*
- [Arch - Improving Performance](https://wiki.archlinux.org/title/Improving_performance)
- [Arch - Gaming](https://wiki.archlinux.org/title/Gaming)
- [Arch - Pro Audio](https://wiki.archlinux.org/title/Pro_Audio)
- [Arch - Network Configuration](https://wiki.archlinux.org/title/Network_configuration)

* Most settings are configured by the installation script.
** A reasonable amount of settings are configured by the installation script.

# TODO:

#### 1.0
- Baikal
- Replace Waybar with EWW
- Theming
  - Everforest Kvantum theme
  - Nemo font color override
  - Krita Kvantum overrides
  - Element Everforest
  - Webcord consistent Everforest
- Fix Japanese Keyboard
- Additions to Install Script
  - Add Floorp Addons to install script
  - Enable multilib
  - Font config
  - Partitioning
  - More aliases
  - More options
  - Add and configure TMUX
  - Check for issues
    - AMD microcode
    - accelerated video decoding
    - dhcpcd or NetworkManager on here???

#### 1.1
- Pro Audio support w/JACK (semi-there)
- Setup Gamescope


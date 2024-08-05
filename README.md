# Arch + Hyprland Dotfiles
### TODO:
- Replace Waybar with EWW
- Everforest w/Kvantum
- Add Floorp Addons to install script
- Pro Audio support w/JACK (semi-there)
- Baikal
- Setup Gamescope

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

-- Additional Tools --
- Kitty (Terminal Emulator)
- Evolution (Mail/Calendar/Contacts)
- Floorp (Web Browser)
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

A full list of packages can be found in [`/bin/installscripts/packages.sh`](/bin/installscripts/packages.sh).

## Installation

To install these dotfiles should be mostly as simple as cloning this repository into your Home directory and running the yet-to-be-documented-or-tested install scripts under `~/bin/installscripts/`.


### Install Arch Linux
Please start from a fresh installation of Arch Linux.  A fresh installation can be attained by following the [Arch Installation Guide on the Arch Wiki](https://wiki.archlinux.org/title/Installation_guide) to the very end.
### ~/bin/installscripts/sysinstall.sh
Run `chmod +x ~/bin/installscripts/sysinstall.sh` followed by `~/bin/installscripts/sysinstall.sh`.  This should kick off the main installation script, which may take a while.
### Configure Hardware & Workspaces
Create `~/.config/hypr/hardware.conf`.  Configure monitors according to [the Hyprland Wiki](https://wiki.hyprland.org/Configuring/Monitors/). Next, create `~/.config/hypr/workspaces.conf` and make workspaces via [workspace rules](https://wiki.hyprland.org/Configuring/Workspace-Rules/).
### For weather on the status bar - 
Make an account on [OpenWeatherMap](https://openweathermap.org/) and get an API Key for One Call API 3.0.  Feel free to limit the calls per day to 1000 so that you do not get charged anything if you wish.

Create `~/.config/waybar/modules/weather/weather_conf.py` and fill in the following;
```
# OpenWeatherMap API and City ID
city_id = <7-digit city ID on OpenWeatherMap>
api_key = "<API Key from OpenWeatherMap>"
```
Once saved, run `chmod a=rwx ~/.config/waybar/modules/weather/weather_conf.py` to finish enabling weather on the status bar.
### Manual Theme Fixes
Some manual fixes for getting themes working for now.  This should be automated later.

First, install **all** of the `org.kde.KStyle.Kvantum` runtimes for flatpaks to be able to use Kvantum themes.
```
# Run this command as many times as necessary
flatpak install org.kde.KStyle.Kvantum
```

Open `lxappearance` in a terminal emulator.
Select `Everforest-Green-Dark` under Widget, and `oomox-Everforest-Dark` under Icon Theme.
At the bottom right, hit apply and close out of the application.

Open the wofi application launcher using `Super+D`, then open `Qt5 Settings`.
Select `kvantum-dark` under Style, `GTK2` under "Standard dialogs", and `darker` under "Color scheme".

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

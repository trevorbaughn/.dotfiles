# Arch + Hyprland Dotfiles

These dotfiles are what I use on my main pc, which is used for multimedia production, primarily across film, photography, and game development.  I also game on this machine.  Many of these dotfiles were initially inspired by someone else's dotfiles - this repository is up as part of contributing to the same community that helped me.  Some key features include;
- English / Japanese Keyboard input
- Timeshift + Rsync Backups
- Floating file manager
- Wayland Compositor
- Everforest themes
  - ... Which are designed to be easy on the eyes!

... Key software includes;
- Waybar (Status Bar)
- Wofi (Application Launcher)
- Hyprpaper (Wallpaper Daemon)
- Swaylock / Swayidle (Lock Screen)
- Hyprshot (Screenshot Tool)
- Mako (Notification Daemon)
- wlogout (Power Button)
- wine, Bottles, Proton (Compatibility Layers)

-- Tools --
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

## Installation

To install these dotfiles should be mostly as simple as cloning this repository into your Home directory and running the yet-to-be-documented-or-tested install scripts under `bin/installscripts/`.


### Archinstall
-------- SKIPPING SOME TO-BE-VERIFIED STEPS ----------
### bin/installscripts/sysinstall.sh
-------- SKIPPING SOME TO-BE-VERIFIED STEPS ----------
### Configure Hardware
-------- SKIPPING SOME TO-BE-VERIFIED STEPS ----------
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

Open `Qt5 Settings` using `Super+D` to open `wofi`.
Select `kvantum-dark` under Style, `GTK2` under "Standard dialogs", and `darker` under "Color scheme"

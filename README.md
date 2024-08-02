# Arch + Hyprland Dotfiles

These dotfiles are what I use on my main pc, which is used for multimedia production, primarily across film, photography, and game development.  I also game on this machine.  Many of these dotfiles were initially inspired by someone else's dotfiles - this repository is up as part of contributing to the same community that helped me.  Some key features include;
- English / Japanese Keyboard input
- Floating file manager
- Wayland Compositor
... Key software includes;
- Waybar (Status Bar)
- Wofi (Application Launcher)
- Hyprpaper (Wallpaper Daemon)
- Swaylock / Swayidle (Lock Screen)
- Hyprshot (Screenshot Tool)
- wlogout (Power Button)
- Kitty (Terminal Emulator)
- Floorp (Web Browser)
- Neovim w/LazyVim (IDE)

## Installation

To install these dotfiles should be mostly as simple as cloning this repository into your `Home/` directory and running the yet-to-be-documented-or-tested install scripts under `bin/installscripts/`.

-------- SKIPPING SOME TO-BE-VERIFIED STEPS ----------
### Archinstall

### bin/installscripts/sysinstall.sh

### For weather on the status bar - 
Create `~/.config/waybar/modules/weather/weather_conf.py` and fill in the following;
```
# OpenWeatherMap API and City ID
city_id = <7-digit city ID on OpenWeatherMap>
api_key = "<API Key from OpenWeatherMap>"
```
Once complete, `chmod a=rwx ~/.config/waybar/modules/weather/weaather_conf.py` to finish enabling weather on the status bar.

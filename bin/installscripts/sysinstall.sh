#!/bin/bash
#https://github.com/trevorbaughn/.dotfiles

# Locale & Keyboard layout
echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
echo "ja_JP.UTF-8 UTF-8" >>/etc/locale.gen
locale-gen
localectl set-keymap --no-convert us
echo LANG=en_US.UTF-8 >/etc/locale.conf

# Start & Enable NetworkManager for internet
systemctl start NetworkManager
systemctl enable NetworkManager

# Install AUR package manager
mkdir $HOME/aur/
cd $HOME/aur/
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Install packages
execute_script "packages.sh"

##############
### Themes ###
##############

# Make directories for GTK themes and icons where the defaults are if they don't exist.
# (NOTE: These lines may not be necessary)
mkdir /usr/share/themes/
mkdir /usr/share/icons/
# Move those directories, whether they existed or not, to $HOME equivalent directores.
mv /usr/share/themes/ $HOME/.themes/
mv /usr/share/icons/ $HOME/.icons/
# Create a symlink between the new and old paths
ln -s $HOME/.themes /usr/share/themes
ln -s $HOME/.icons /usr/share/icons
# Set Flatpaks to have access to those directories, as well as the GTK4 themes in xdg-config.
flatpak override --user --filesystem=$HOME/.themes
flatpak override --user --filesystem=$HOME/.icons
flatpak override --user --filesystem=xdg-config/gtk-4.0
# Set the GTK Theme and GTK Icons for non-Flatpaks (everforest-gtk-theme-git from AUR)
gsettings set org.gnome.desktop.interface gtk-theme Everforest-Green-Dark
gsettings set org.gnome.desktop.interface icon-theme Everforest-Dark
# Set the same for Flatpaks
flatpak override --user --env=GTK_THEME=Everforest-Green-Dark
flatpak override --user --env=ICON_THEME=oomox-Everforest-Dark
# Set QT Flatpaks to use the currently active Kvantum theme
flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum --filesystem=xdg-config/Kvantum:ro

##############
##############
##############

# Create directories for bookmarking
xdg-user-dirs-update
mkdir $HOME/Pictures/Screenshots/
mkdir $HOME/Art/
mkdir $HOME/GameProjects/
mkdir $HOME/Applications/

# MIME
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# Kitty
ln -s /usr/bin/kitty /usr/bin/gnome-terminal # Makes certain gnome apps work w/Kitty

# Nemo
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty

# User Groups
gpasswd -a $(whoami) wheel
gpasswd -a $(whoami) gamemode
gpasswd -a $(whoami) audio
gpasswd -a $(whoami) realtime

# Unmute ALSA
amixer sset Master unmute
amixer sset Speaker unmute
amixer sset Headphone unmute

# Enable SSH & DHCP
systemctl enable sshd
systemctl enable dhcpcd

# Enable SSD Trim
systemctl enable fstrim.timer

# Enable Time Sync
systemctl enable ntpd
timedatectl set-ntp true

# Increase vm.max_map_count (Game Compatibility)
# https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
echo "vm.max_map_count = 2147483642" >/etc/systcl.d/80-gamecompatibility.conf

# Delay after failed login
echo "auth optional pam_faildelay.so delay=4000000" >>/etc/pam.d/system-login

# Krita
flatpak override --env=KRITA_NO_STYLE_OVERRIDE=1 org.kde.krita

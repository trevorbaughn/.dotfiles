#!/bin/bash
#https://github.com/trevorbaughn/.dotfiles

#TODO: Add files under /etc directory via cp command automation

loadkeys us

execute_script "packages.sh"

# Theme (still need to set in lxappearance???)
mkdir /usr/share/themes/
mkdir /usr/share/icons/
mv /usr/share/themes/ $HOME/.themes/
mv /usr/share/icons/ $HOME/.icons/
ln -s $HOME/.themes /usr/share/themes
ln -s $HOME.icons /usr/share/icons
flatpak override --filesystem=$HOME/.themes
flatpak override --filesystem=$HOME/.icons
#flatpak override --filesystem=xdg-config/gtk-4.0
gsettings set org.gnome.desktop.interface gtk-theme Everforest-Green-Dark
gsettings set org.gnome.desktop.interface icon-theme Everforest-Dark
flatpak override --env=GTK_THEME=Everforest-Green-Dark
flatpak override --env=ICON_THEME=oomox-Everforest-Dark

# Create directories for bookmarking
mkdir $HOME/Art/
mkdir $HOME/Pictures/
mkdir $HOME/Videos/
mkdir $HOME/Documents/
mkdir $HOME/Music/
mkdir $HOME/Pictures/Screenshots/
mkdir $HOME/GameProjects/
mkdir $HOME/Applications/

# MIME
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# Kitty
ln -s /usr/bin/kitty /usr/bin/gnome-terminal # Makes certain GNOME apps work with Kitty

# Nemo
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty

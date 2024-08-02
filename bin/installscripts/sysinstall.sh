#!/bin/bash
#https://github.com/trevorbaughn/dotfiles

#TODO: Add files under /etc directory via cp command automation

loadkeys us

execute_script "packages.sh"

ln -s /usr/bin/kitty /usr/bin/gnome-terminal #makes certain gnome apps work with kitty

#Theme (still need to set in lxappearance???)
rm -rf /usr/share/themes/
rm -rf /usr/share/icons/
mkdir ~/.themes/
mkdir ~/.icons/
ln -s ~/.themes /usr/share/themes
ln -s ~/.icons /usr/share/icons
flatpak override --filesystem=$HOME/.themes
flatpak override --filesystem=$HOME/.icons
gsettings set org.gnome.desktop.interface gtk-theme Everforest-Green-Dark
flatpak override --env=GTK_THEME=Everforest-Green-Dark
flatpak override --env=ICON_THEME=breeze-dark

#Create directories for bookmarking
mkdir ~/Art/
mkdir ~/Pictures/
mkdir ~/Videos/
mkdir ~/Documents/
mkdir ~/Music/
mkdir ~/Pictures/Screenshots/
mkdir ~/GameProjects/
mkdir ~/Applications/

#!/bin/bash
#https://github.com/trevorbaughn/dotfiles

#TODO: Add files under /etc directory via cp command automation

loadkeys us

execute_script "packages.sh"

ln -s /usr/bin/kitty /usr/bin/gnome-terminal #makes certain gnome apps work with kitty

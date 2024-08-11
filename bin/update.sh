#!/bin/bash

Cyan='\e[0;36m'
White='\e[0;00m'

echo "[$Cyan*$White] Checking Pacman + AUR packages..."
yay -Syu --noconfirm

echo "[$Cyan*$White] Checking Flatpak packages..."
flatpak update --noninteractive

echo "[$Cyan*$White] Checking Neovim plugins..."
nvim --headless "+Lazy! sync" +qa

echo "Done checking for updates. - Press [Enter] to continue."
read
exit 0

#!/usr/bin/env bash

echo "Installing Packages..."

PACKAGES=(
	"swaylock",
	"swayidle",
	"nemo",
	"flatpak",
	"kvantum",
	"kvantum-qt5",
	"qt5ct",
	"qt6ct",
	"qt5-base",
	"qt6-base",
	"gtk3",
	"gtk4",
)

AUR_PACKAGES=(
	"gtk",
	"gtk2",
	"gtk5-styleplugins",
	"qt6gtk2",
	"gnome-themes-extra-gtk2",
	"adwaita-qt6-git",
	"adwaita-qt5-git",
	"qadwaita-decorations-qt5",
	"qadwaita-decorations-qt6",
)

FLATPAK_PACKAGES=(
	"org.kde.KStyle.Kvantum",
	"org.kde.KStyle.Adwaita",
	"org.winehq.Wine.mono",
	"org.winehq.Wine.gecko",
	"dev.vencord.Vesktop",
	"com.usebottles.bottles",
	"com.obsproject.Studio",
	"one.ablaze.floorp",
	"org.kde.krita",
	"org.videolan.VLC",
	"org.kde.kdenlive",
	"org.libreoffice.LibreOffice",
	"org.inkscape.Inkscape",
	"org.gimp.GIMP",
	"im.riot.Riot",
	"com.vscodium.codium",
	"md.obsidian.Obsidian",
	"us.zoom.Zoom"
)

for PACKAGE in "${PACKAGES[@]}"; do
	echo "INSTALLING: ${PACKAGE}"
	sudo pacman -S "$PACKAGE" --noconfirm --needed
done

for PACKAGE in "${AUR_PACKAGES[@]}"; do
	echo "INSTALLING: ${PACKAGE}"
	paru -S --noconfirm "$PACKAGE"
done

for PACKAGE in "${FLATPAK_PACKAGES[@]}"; do
	echo "INSTALLING: ${PACKAGE}"
	flatpak install --noninteractive "$PACKAGE"
done

echo "GSettings..."

gsettings set org.gtk.Settings.FileChooser startup-mode cwd

#temp hardcoded... hopefully can get lxappearance working
gsettings set org.gnome.desktop.interface gtk-theme Gruvbox-Orange-Dark-Medium
gsettings set org.gnome.desktop.interface icon-theme Gruvbox-Dark

echo "Done!"

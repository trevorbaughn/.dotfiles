#!/usr/bin/env bash

echo "Installing Packages..."

PACKAGES=(
	"swaybg",
	"swaylock",
	"swayidle",
	"nemo",
	"mako",
	"waybar",
	"flatpak",
	"kvantum",
	"kvantum-qt5",
	"qt5ct",
	"qt6ct",
	"qt5-base",
	"qt6-base",
	"gtk3",
	"gtk4",
	"pro-audio",
	"ranger",
	"tldr",
	"colordiff",
	"atop",
	"fcitx5-im",
	"fcitx5-mozc",
	"sway-contrib",
	"cliphist",
	"tmux",
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
	"godot-mono",
	"librewolf-bin",
	"all-repository-fonts",
	"ttf-google-fonts-git",
	"tex-gyre-math-fonts",
	"ttf-hanazono",
	"ttf-koruri",
	"ttf-monapo",
	"ttf-mplus-git",
	"ttf-kanjistrokeorders"
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
	"us.zoom.Zoom",
	"org.gnome.Evolution",
	"org.darktable.Darktable",
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

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Cloning Dotfiles"
cd $HOME
cd ..
git clone https://github.com/trevorbaughn/.dotfiles.git
shopt -s dotglob
cp -R .dotfiles/* $HOME
mv $HOME/.git $HOME/.dotfiles


echo "GSettings..."

gsettings set org.gtk.Settings.FileChooser startup-mode cwd
gsettings set org.cinnamon.desktop.default-applications.terminal exec foot
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Temp have the flatpak overrides here
flatpak override --user --env=KRITA_NO_STYLE_OVERRIDE=1 org.kde.krita
flatpak override --user --filesystem=$HOME/.themes
flatpak override --user --filesystem=$HOME/.local/share/icons
flatpak override --user --filesystem=xdg-config/gtk-4.0
flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum --filesystem=xdg-config/Kvantum:ro

#temp hardcoded... hopefully can get lxappearance working eventually
gsettings set org.gnome.desktop.interface gtk-theme Gruvbox-Orange-Dark-Medium
gsettings set org.gnome.desktop.interface icon-theme Gruvbox-Dark


echo "Languages"
sudo sed -i '/ja_JP.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
sudo sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen


echo "Done!"

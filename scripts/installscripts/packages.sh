#!/bin/bash
#https://github.com/trevorbaughn/dotfiles

extra=(
	kitty
	nvim
)

environment=(
	cmake
	curl
	hyprpaper
	imagemagick
	mako
	meson
	network-manager-applet
	pamixer
	pavucontrol
	pipewire
	pipewire-alsa
	polkit-kde-agent
	python-requests
	qt5-wayland
	qt6-wayland
	qt5ct
	qt6ct
	qt6-svg
	ripgrep
	slurp
	swayidle
	swaylock
	waybar
	wget
	wireplumber
	wl-clipboard
	wofi
	xdg-desktop-portal-hyprland
	xdg-user-dirs
	xdg-utils
	flatpak
)

for PKG1 in "${environment[@]}" "${extra[@]}"; do
	sudo pacman -S --noconfirm "$PKG1" | tee -a "$LOG"
	if [ $? -ne 0 ]; then
		echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
		exit 1
	fi
done

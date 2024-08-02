#!/bin/bash
#https://github.com/trevorbaughn/dotfiles

LOG="sysinstall-$(date +%d-%H%M%S)-packages.log"

extra=(
  kitty
  lxappearance
  neofetch
  nvim
)

flatpaks=(
  com.felipekinoshita.Kana
  com.github.qarmin.czkawka
  com.obsproject.Studio
  com.usebottles.bottles
  com.slack.slack
  im.riot.Riot
  io.github.spacingbat3.webcord
  io.lmms.LMMS
  md.obsidian.Obsidian
  one.ablaze.floorp
  org.audacityteam.Audacity
  org.gimp.GIMP
  org.inkscape.Inkscape
  org.kde.kdenlive
  org.kde.krita
  org.libreoffice.LibreOffice
  org.nomacs.ImageLounge
  org.videolan.VLC
  us.zoom.Zoom
)

environment=(
  aliases
  base-devel
  cmake
  composer
  curl
  dhcpcd
  dotnet-runtime
  dotnet-sdk
  everforest-gtk-theme-git
  fd
  flatpak
  gamemode
  gamescope
  go
  gtk2
  gtk3
  gtk4
  gtk-engine-murrine
  hyprland
  hyprpaper
  hyprshot
  imagemagick
  java-environment-common
  java-runtime-common
  jdk-openjdk
  julia
  lib32-gamemode
  linux-headers
  lua
  luarocks
  mako
  meson
  network-manager-applet
  nemo
  nodejs
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  npm
  ntp
  openssh
  pamixer
  pavucontrol
  php
  pipewire
  pipewire-alsa
  polkit-kde-agent
  python
  python-pip
  python-requests
  qt5-wayland
  qt6-wayland
  qt5ct
  qt6ct
  qt6-svg
  ripgrep
  ruby
  rubygems
  rust
  sassc
  slurp
  sshd
  swayidle
  swaylock
  tar
  tree-sitter
  tree-sitter-cli
  ttf-firacode-nerd
  unzip
  v4l2loopback-dkms
  waybar
  wget
  wireplumber
  wine
  wl-clipboard
  wlogout
  wofi
  xdg-desktop-portal-hyprland
  xdg-user-dirs
  xdg-utils
)

for PKG1 in "${environment[@]}" "${extra[@]}"; do
  sudo pacman -S --noconfirm "$PKG1" | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

for PGK1 in "${flatpaks[@]}"; do
  sudo flatpak install --noninteractive "$PKG1" | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

clear

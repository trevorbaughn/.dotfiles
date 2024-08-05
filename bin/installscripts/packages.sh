#!/bin/bash
#https://github.com/trevorbaughn/.dotfiles

LOG="sysinstall-$(date +%d-%H%M%S)-packages.log"

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
  org.darktable.Darktable
  org.gimp.GIMP
  org.inkscape.Inkscape
  org.kde.kdenlive
  org.kde.krita
  org.kde.KStyle.Kvantum #install all runtimes how? figure out
  org.libreoffice.LibreOffice
  org.nomacs.ImageLounge
  org.videolan.VLC
  us.zoom.Zoom
)

clitools=(
  cargo
  cmake
  curl
  fd
  ripgrep
  slurp
  tar
  unzip
  wget
  wine
)

nemo=(
  nemo
  nemo-emblems
  nemo-fileroller
  nemo-preview
  nemo-image-converter
)

themes=(
  lxappearance
  everforest-gtk-theme-git
  gtk2
  gtk3
  gtk4
  gtk-engine-murrine
  kvantum
  kvantum-qt5
  qt5-styleplugins
  qt5-svg
  qt5-wayland
  qt6-wayland
  qt5ct
  qt6ct
  qt6-svg
)

audio=(
  pamixer
  pavucontrol
  pipewire
  pipewire-alsa
  wireplumber
)

fonts=(
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  ttf-firacode-nerd
  ttf-liberation
)

programminglanguages=(
  dotnet-runtime
  dotnet-sdk
  go
  java-environment-common
  java-runtime-common
  jdk-openjdk
  julia
  lua
  luarocks
  nodejs
  php
  python
  python-pip
  python-requests
  ruby
  rubygems
  rust
  sassc
)

environment=(
  aliases
  base-devel
  composer
  dhcpcd
  flatpak
  gamemode
  gamescope
  hyprland
  hyprpaper
  hyprshot
  imagemagick
  kitty
  lib32-gamemode
  linux-headers
  lutris
  mako
  meson
  network-manager-applet
  neofetch
  npm
  ntp
  nvim
  openssh
  polkit-kde-agent
  sshd
  steam
  swayidle
  swaylock
  tree-sitter
  tree-sitter-cli
  v4l2loopback-dkms
  waybar
  wget
  wine
  wl-clipboard
  wlogout
  wofi
  xdg-desktop-portal-hyprland
  xdg-user-dirs
  xdg-utils
)

for PKG1 in "${environment[@]}" "${programminglanguages[@]}" "${fonts[@]}" "${themes[@]}" "${audio[@]}" "${clitools[@]}" ${nemo[@]}"; do
  sudo yay -S --noconfirm "$PKG1" | tee -a "$LOG"
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

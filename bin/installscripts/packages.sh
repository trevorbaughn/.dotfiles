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
  runtime/org.kde.KStyle.Kvantum/x86_64/5.15-22.08
  runtime/org.kde.KStyle.Kvantum/x86_64/5.15-23.08
  runtime/org.kde.KStyle.Kvantum/x86_64/6.5
  runtime/org.kde.KStyle.Kvantum/x86_64/6.6
  runtime/org.kde.KStyle.Kvantum/x86_64/5.15
  runtime/org.kde.KStyle.Kvantum/x86_64/5.15-21.08
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
  htop
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
  alsa-firmware
  alsa-oss
  alsa-plugins
  alsa-utils
  alsamixer
  apulse
  jack_mixer
  lib32-pipewire-jack
  pamixer
  pavucontrol
  pipewire
  pipewire-alsa
  pipewire-jack
  pipewire-jack-client
  qjackctl
  sof-firmware
  wireplumber
)

fonts=(
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  ttf-firacode-nerd
  ttf-liberation
  ttf-opensans
)

programminglanguages=(
  composer
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

minimal=(
  base
  base-devel
  linux
  linux-firmware
  e2fsprogs
  dhcpcd
  networkmanager
  git
  neovim
  man-db
  man-pages
  sudo
  texinfo
)

environment=(
  aliases
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
  mako
  meson
  neofetch
  npm
  ntp
  openssh
  pipewire-v4l2
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
  xorg-xeyes
  xorg-xwayland
  xwaylandvideobridge-git
)

for PKG1 in "${environment[@]}" "${programminglanguages[@]}" "${fonts[@]}" "${themes[@]}" "${audio[@]}" "${clitools[@]}" ${nemo[@]}"; do
  sudo paru -S --noconfirm "$PKG1" | tee -a "$LOG"
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

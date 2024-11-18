# Inject variables
Cyan="$(sed -n 1p ${HOME}/bin/installscripts/install-variables)"
White="$(sed -n 2p ${HOME}/bin/installscripts/install-variables)"
Red="$(sed -n 3p ${HOME}/bin/installscripts/install-variables)"
system_cpu="$(sed -n 4p ${HOME}/bin/installscripts/install-variables)"
system_gpu="$(sed -n 5p ${HOME}/bin/installscripts/install-variables)"
unity_install="$(sed -n 6p ${HOME}/bin/installscripts/install-variables)"
unreal_install="$(sed -n 7p ${HOME}/bin/installscripts/install-variables)"
godot_install="$(sed -n 8p ${HOME}/bin/installscripts/install-variables)"
davinci_install="$(sed -n 9p ${HOME}/bin/installscripts/install-variables)"

# Switch to installscript directory
cd $HOME/bin/installscripts

# Install packages
chmod +x install-packages.sh
./install-packages.sh ${LOG} ${Cyan} ${White} ${Red} ${system_cpu} ${system_gpu} ${unity_install} ${unreal_install} ${godot_install} ${davinci_install}

# Install theme
chmod +x theme-installer.sh
./theme-installer.sh ${LOG} ${Cyan} ${White} ${Red}

#############################
### General System Config ###
#############################

# Create directories for bookmarking
xdg-user-dirs-update
mkdir -pvm 776 $HOME/Pictures/Screenshots/
mkdir -vm 776 $HOME/Art/
mkdir -vm 776 $HOME/Projects/
mkdir -vm 776 $HOME/Applications/

# Wine TKG
cd $HOME/Applications
git clone https://github.com/Frogging-Family/wine-tkg-git.git
cd wine-tkg-git
makepkg -si

# MIME
echo -e "[${Cyan}*${White}] Configuring MIMEs..."
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# Enable Misc. Daemons
echo -e "[${Cyan}*${White}] Start/Enabling sshd and fstrim.timer daemons..."
systemctl enable sshd         #SSH
systemctl enable fstrim.timer #SSD Periodic (weekly) Trim

# Unmute ALSA
echo -e "[${Cyan}*${White}] Unmuting ALSA"
amixer sset Master unmute
amixer sset Speaker unmute
amixer sset Headphone unmute

# Increase vm.max_map_count (Game Compatibility)
# https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
echo -e "[${Cyan}*${White}] Increasing vm.max_map_count to 2147483642 for game compatibility"
echo "vm.max_map_count = 2147483642" >/etc/systcl.d/80-gamecompatibility.conf

# File Chooser
echo -e "[${Cyan}*${White}] Setting file chooser startup-mode to cwd"
gsettings set org.gtk.Settings.FileChooser startup-mode cwd

# Kitty fix for gnome & cinnamon applications
echo -e "[${Cyan}*${White}] Fixing kitty terminal gnome & cinnamon associations"
ln -s /usr/bin/kitty /usr/bin/gnome-terminal
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty

# Krita
flatpak override --env=KRITA_NO_STYLE_OVERRIDE=1 org.kde.krita

# Unreal Engine
if [ unreal_install = y ]; then
  chmod -R a+rwX /opt/unreal-engine/Engine
fi

cd $HOME

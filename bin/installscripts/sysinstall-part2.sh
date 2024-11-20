# Inject variables
Cyan="$(sed -n 1p /install-variables)"
White="$(sed -n 2p /install-variables)"
Red="$(sed -n 3p /install-variables)"
root_password="$(sed -n 4p /install-variables)"
system_cpu="$(sed -n 5p /install-variables)"
system_gpu="$(sed -n 6p /install-variables)"
unity_install="$(sed -n 7p /install-variables)"
unreal_install="$(sed -n 8p /install-variables)"
godot_install="$(sed -n 9p /install-variables)"
davinci_install="$(sed -n 10p /install-variables)"

#Ignore history for commands that need password piped in
export HISTIGNORE='*sudo -S*'
sudopass="echo "$root_password" | sudo -S -v"

##########################
### Generate initramfs ###
##########################

modules=""
hooks="base udev autodetect"

# microcode or no?
if [ "$system_cpu" = "amd" ]; then
  hooks+=" microcode"
elif [ "$system_cpu" = "intel" ]; then
  hooks+=" microcode"
elif [ "$system_cpu" = "nvidia" ]; then
  echo ""
else
  echo "[${Red}WARNING${White}]${Red} CPU install setting not correctly set, not optimizing microcode for CPU.$White"
fi

# GPU-specific
if [ "$system_gpu" = "amd" ]; then
  modules+="amdgpu"
elif [ "$system_gpu" = "intel" ]; then
  modules+="i915"
elif [ "$system_gpu" = "nvidia" ]; then
  modules+="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
else
  echo "[${Red}WARNING${White}]${Red} GPU install setting not correctly set, not optimizing initramfs for GPU.$White"
fi

hooks+=" modconf kms keyboard keymap consolefont numlock block filesystems fsck"

echo -e "[${Cyan}*${White}] Setting /etc/mkinitcpio.conf modules - ($modules)"
sudopass -i sed -i "/^MODULES=/ c\MODULES=($modules)" /etc/mkinitcpio.conf

echo -e "[${Cyan}*${White}] Setting /etc/mkinitcpio.conf hooks - ($hooks)"
sudopass -i sed -i "/^HOOKS=/ c\HOOKS=($hooks)" /etc/mkinitcpio.conf

#cat /etc/mkinitcpio.conf

echo -e "[${Cyan}*${White}] Generating new initramfs..."
mkinitcpio -P

#######################
### Dots & Packages ###
#######################

# Install dotfiles
sudopass -s <<EOF
cd $HOME
cd ..
git clone https://github.com/trevorbaughn/.dotfiles.git
shopt -s dotglob
cp -R .dotfiles/* $HOME
mv $HOME/.git $HOME/.dotfiles
rm -rf .dotfiles
EOF

# Switch to installscript directory
cd $HOME/bin/installscripts

# Install packages
echo -e "[${Cyan}*${White}] Installing Packages..."
sudopass -s chmod +x install-packages.sh
./install-packages.sh ${LOG} ${Cyan} ${White} ${Red} ${system_cpu} ${system_gpu} ${unity_install} ${unreal_install} ${godot_install} ${davinci_install}

# Install theme
echo -e "[${Cyan}*${White}] Installing Theme"
sudopass -s chmod +x theme-installer.sh
#./theme-installer.sh ${LOG} ${Cyan} ${White} ${Red}

# Enable SDDM
echo -e "[${Cyan}*${White}] Enabling SDDM"
sudopass -s <<EOF
systemctl enable sddm
touch /etc/sddm.conf.d/rootless-wayland.conf
echo "[General]" >"/etc/sddm.conf.d/rootless-wayland.conf"
echo "DisplayServer=wayland" >>"/etc/sddm.conf.d/rootless-wayland.conf"
EOF


#############################
### General System Config ###
#############################

# Create directories for bookmarking
echo -e "[${Cyan}*${White}] Creating Home directories"
xdg-user-dirs-update
mkdir -pvm 776 $HOME/Pictures/Screenshots/
mkdir -vm 776 $HOME/Art/
mkdir -vm 776 $HOME/Projects/
mkdir -vm 776 $HOME/Applications/

# Wine TKG
echo -e "[${Cyan}*${White}] Installing Wine TKG"
cd $HOME/Applications
git clone https://github.com/Frogging-Family/wine-tkg-git.git
cd wine-tkg-git
makepkg -si

# MIME
echo -e "[${Cyan}*${White}] Configuring MIMEs..."
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# Enable Misc. Daemons
echo -e "[${Cyan}*${White}] Start/Enabling sshd and fstrim.timer daemons..."
sudopass -i <<EOF
systemctl enable sshd         #SSH
systemctl enable fstrim.timer #SSD Periodic (weekly) Trim
EOF

# Unmute ALSA
echo -e "[${Cyan}*${White}] Unmuting ALSA"
amixer sset Master unmute
amixer sset Speaker unmute
amixer sset Headphone unmute

# Increase vm.max_map_count (Game Compatibility)
# https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
echo -e "[${Cyan}*${White}] Increasing vm.max_map_count to 2147483642 for game compatibility"
sudopass -s echo "vm.max_map_count = 2147483642" >/etc/systcl.d/80-gamecompatibility.conf

# File Chooser
echo -e "[${Cyan}*${White}] Setting file chooser startup-mode to cwd"
gsettings set org.gtk.Settings.FileChooser startup-mode cwd

# Kitty fix for gnome & cinnamon applications
echo -e "[${Cyan}*${White}] Fixing kitty terminal gnome & cinnamon associations"
sudopass -s ln -s /usr/bin/kitty /usr/bin/gnome-terminal
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty

# Krita
flatpak override --env=KRITA_NO_STYLE_OVERRIDE=1 org.kde.krita

# Unreal Engine
if [ unreal_install = y ]; then
  sudopass -s chmod -R a+rwX /opt/unreal-engine/Engine
fi

cd $HOME

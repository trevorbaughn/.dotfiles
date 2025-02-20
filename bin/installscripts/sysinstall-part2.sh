# Inject variables
Cyan="$(sed -n 1p /install-variables)"
White="$(sed -n 2p /install-variables)"
Red="$(sed -n 3p /install-variables)"
system_cpu="$(sed -n 4p /install-variables)"
system_gpu="$(sed -n 5p /install-variables)"
unity_install="$(sed -n 6p /install-variables)"
unreal_install="$(sed -n 7p /install-variables)"
godot_install="$(sed -n 8p /install-variables)"
davinci_install="$(sed -n 9p /install-variables)"
openweathermap_apikey="$(sed -n 10p /install-variables)"
openweathermap_city="$(sed -n 11p /install-variables)"
keyboard_layouts="$(sed -n 12p /install-variables)"
keyboard_layout_variants="$(sed -n 13p /install-variables)"

# Logging
LOG="sysinstall-part2-$(date +%d-%H%M%S).log"

echo -e "[${Cyan}*${White}] What is your root password?"
echo -n "root password: "
read -r -s root_password

#Ignore history for commands that need password piped in
export HISTIGNORE='*sudo -S*'

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
echo -e "$root_password\n" | sudo -S -v
sudo -i sed -i "/^MODULES=/ c\MODULES=($modules)" /etc/mkinitcpio.conf

echo -e "[${Cyan}*${White}] Setting /etc/mkinitcpio.conf hooks - ($hooks)"
echo -e "$root_password\n" | sudo -S -v
sudo -i sed -i "/^HOOKS=/ c\HOOKS=($hooks)" /etc/mkinitcpio.conf

#cat /etc/mkinitcpio.conf

echo -e "[${Cyan}*${White}] Generating new initramfs..."
mkinitcpio -P

#######################
### Dots & Packages ###
#######################

# Install dotfiles
echo -e "[${Cyan}*${White}] Cloning dotfiles repository..."
echo -e "$root_password\n" | sudo -S -v
sudo -s <<EOF
cd $HOME
cd ..
git clone https://github.com/trevorbaughn/.dotfiles.git
shopt -s dotglob
cp -R .dotfiles/* $HOME
mv $HOME/.git $HOME/.dotfiles
rm -rf .dotfiles
EOF

# Set Hardware-specific environment variables in .bashrc
if [ "$system_gpu" = "amd" ]; then
  echo -e "$root_password\n" | sudo -S -v
  sudo -i tee -a $HOME/.bashrc > /dev/null <<EOF

################
### HARDWARE ###
################

export DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1
export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/radeon_icd.i686.json:/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
EOF
fi

# Setup multi-language support
echo -e "[${Cyan}*${White}] Setting up multi-language support"
keyboard_layouts=($keyboard_layouts)
kb_layouts=us
keyboard_layout_variants=($keyboard_layout_variants)
for layout in "${keyboard_layouts[@]}"; do
  kb_layouts="$kb_layouts,$layout"
  language_lists="$language_lists ${layout}-language-support" #add language-specific package-lists
done
language_lists=($language_lists)
echo -e "$root_password\n" | sudo -S -v
sudo -i sed -i "/^    kb_layout = us/ c\    kb_layout = ${kb_layouts}" $HOME/.config/hypr/hyprland.conf
sudo -i sed -i "/^    kb_variant = qwerty/ c\    kb_variant = ${keyboard_layout_variants}" $HOME/.config/hypr/hyprland.conf

# Switch to installscript directory
cd $HOME/bin/installscripts

# Install packages
echo -e "[${Cyan}*${White}] Installing Packages..."
echo -e "$root_password\n" | sudo -S -v
sudo -s chmod +x install-packages.sh
./install-packages.sh ${LOG} ${Cyan} ${White} ${Red} ${system_cpu} ${system_gpu} ${unity_install} ${unreal_install} ${godot_install} ${davinci_install} ${root_password} ${language_lists}

# Install theme
echo -e "[${Cyan}*${White}] Installing Theme"
echo -e "$root_password\n" | sudo -S -v
sudo -s chmod +x theme-installer.sh
#./theme-installer.sh ${LOG} ${Cyan} ${White} ${Red}

# Update permissions (Might be bad?)
echo -e "$root_password\n" | sudo -S -v
sudo -i find $HOME/.var -type d -exec chmod 755 {} +
sudo -i find $HOME/.var -type f -exec chmod 644 {} +

# Enable SDDM
echo -e "[${Cyan}*${White}] Enabling SDDM"
echo -e "$root_password\n" | sudo -S -v
sudo -i mkdir -p /etc/sddm.conf.d
echo -e "$root_password\n" | sudo -S -v
sudo -i tee /etc/sddm.conf.d/general.conf > /dev/null <<EOF
[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=Hyprland
EOF
echo -e "$root_password\n" | sudo -S -v
#sudo -i systemctl enable sddm

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

# MIME
echo -e "[${Cyan}*${White}] Configuring MIMEs..."
echo -e "$root_password\n" | sudo -S -v
sudo -i xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# SSH
echo -e "$root_password\n" | sudo -S -v
sudo -i mkdir -p /etc/ssh/sshd_config.d
sudo -i tee /etc/ssh/sshd_config.d/20-deny_root.conf > /dev/null <<EOF
PermitRootLogin no
EOF

# Enable Misc. Daemons
echo -e "[${Cyan}*${White}] Start/Enabling sshd and fstrim.timer daemons..."
echo -e "$root_password\n" | sudo -S -v
sudo -i <<EOF
systemctl enable sshd         #SSH
systemctl enable fstrim.timer #SSD Periodic (weekly) Trim
systemctl enable cups.socket  #Daemon that starts cups.service when needed, but not until then (for printing)
EOF

# Unmute ALSA
echo -e "[${Cyan}*${White}] Unmuting ALSA"
amixer sset Master unmute
amixer sset Speaker unmute
amixer sset Headphone unmute

# Increase vm.max_map_count (Game Compatibility)
# https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
echo -e "[${Cyan}*${White}] Increasing vm.max_map_count to 2147483642 for game compatibility"
echo -e "$root_password\n" | sudo -S -v
sudo -i touch /etc/systcl.d
sudo -s tee -a /etc/systcl.d/80-gamecompatibility.conf > /dev/null <<EOF
vm.max_map_count = 2147483642
EOF

# Setting up OpenWeatherMap for Waybar 
if [ -z "$openweathermap_apikey" ]; then
  echo -e "[${Cyan}*${White}] Not setting up OpenWeatherMap"
else
  echo -e "[${Cyan}*${White}] Setting up OpenWeatherMap"
  sudo -i tee $HOME/.config/waybar/modules/weather/weather_conf.py > /dev/null <<EOF
# OpenWeatherMap API and City ID
city_id = $openweathermap_city
api_key = $openweathermap_apikey
EOF
sudo -i chmod a+x $HOME/.config/waybar/modules/weather/weather_conf.py
fi

# File Chooser
echo -e "[${Cyan}*${White}] Setting file chooser startup-mode to cwd"
gsettings set org.gtk.Settings.FileChooser startup-mode cwd

# Kitty fix for gnome & cinnamon applications
echo -e "[${Cyan}*${White}] Fixing kitty terminal gnome & cinnamon associations"
echo -e "$root_password\n" | sudo -S -v
sudo -s ln -s /usr/bin/kitty /usr/bin/gnome-terminal
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty

# Krita
flatpak override --env=KRITA_NO_STYLE_OVERRIDE=1 org.kde.krita

# Unreal Engine
if [ unreal_install = y ]; then
  echo -e "$root_password\n" | sudo -S -v
  sudo -s chmod -R a+rwX /opt/unreal-engine/Engine
fi

rm /install-variables

cd $HOME

echo -e "[${Cyan}*${White}] Press Enter to Reboot..."
read -r dummy

#reboot

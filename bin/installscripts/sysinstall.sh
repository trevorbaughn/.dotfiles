#!/bin/bash
#https://github.com/trevorbaughn/.dotfiles

LOG="sysinstall-$(date +%d-%H%M%S)-packages.log"

# Install Script Colors
Red='\e[0;31m'
Green='\e[0;32m'
Cyan='\e[0;36m'
White='\e[0;00m'

# Variables
package_lists_path=$HOME/bin/installscripts/packages/
flatpak_lists=(end-user-flatpaks flatpak-runtimes-and-compatibility)
pacman_lists=(minimal cli-tools audio fonts themes programming-languages desktop-environment)

#################
### Questions ###
#################

echo -e "[${Cyan}*${White}] What keymap will this system default to? (ex. 'us' for USA)"
echo -n "keymap: "
read -r system_keymap

echo -e "[${Cyan}*${White}] What should the system network hostname be? -- NOTE: This is NOT the user."
echo -n "hostname: "
read -r system_hostname

echo -e "[${Cyan}*${White}] What time zone Region do you wish to set the system clock to? (City is next)"
echo -n "region: "
read -r system_clock_region
echo -e "[${Cyan}*${White}] What time zone City do you wish to set the system clock to?"
echo -n "city: "
read -r system_clock_city

echo -e '[${Cyan}*${White}] Is the system CPU; "amd", "nvidia", or "intel"?'
echo -n "cpu: "
read -r system_cpu
echo -e '[${Cyan}*${White}] Is the system GPU; "amd", "nvidia", or "intel"?'
echo -n "gpu: "
read -r system_gpu

echo -e "[${Cyan}*${White}] What will the default user's username be?"
echo -n "username: "
read -r user_username

echo -e "[${Cyan}*${White}] What drive would you like to install on? WARNING: ALL ORIGINAL DATA WILL BE LOST"
echo -n "/dev/"
read -r device

echo -e "[${Cyan}*${White}] How much SWAP memory do you wish to have? Leave blank for none. \
-- ex. '+8GiB' for 8 gigabytes \
[${Cyan}NOTE${White}] It is recommended to use an equal amount of SWAP as you have RAM for the hibernation feature."
echo -n "SWAP: "
read -r swap

echo -e "[${Cyan}*${White}] Would you like to install Unreal Engine 5? \
-- NOTE: It is recommended to ensure the root partition has enough space. \
~40GB per engine version should be adequate."
echo -n "y/n: "
read -r unreal_install

echo -e "[${Cyan}*${White}] Would you like to install the Unity Game Engine?"
echo -n "y/n: "
read -r unity_install

echo -e "[${Cyan}*${White}] Would you like to install the Godot 4 Game Engine?"
echo -n "y/n/y-mono: "
read -r godot_install

echo -e "[${Cyan}*${White}] Would you like to install Davinci Resolve?"
echo -n "y/n/y-studio: "
read -r davinci_install

#TODO:###################################
### Partition, Format, & Mount Drives ###
#########################################

sgdisk -Z /dev/$device

if [ $(cat /sys/firmware/efi/fw_platform_size) -eq 64 ]; then
  echo -e "[${Cyan}*${White}] Detected ${Green}64-bit x64 UEFI${White} mode"
  echo -e "[${Cyan}*${White}] Creating boot partition"
  sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:boot /dev/$device # boot partition
elif [ $(cat /sys/firmware/efi/fw_platform_size) -eq 32 ]; then
  echo -e "[${Cyan}*${White}] Detected ${Green}32-bit IA32 UEFI${White} mode"
  exit #TODO:MOUNT THIS
else
  echo -e "[${Cyan}*${White}] Detected ${Green}BIOS${White} mode"
  exit # TODO: MOUNT THIS AND DO GRUB STUFF
  echo -e "[${Cyan}*${White}] Creating GRUB and boot partition"
  sgdisk -n 0:0:+1MiB -t 0:ef02 -c 0:grub /dev/$device # grub partition
  sgdisk -n 0:0:+1GiB -t 0:ea00 -c 0:boot /dev/$device # boot partition
fi

if [ -z "$swap" ]; then
  echo -e "[${Cyan}*${White}] Not creating a SWAP partition"
else
  echo -e "[${Cyan}*${White}] Creating SWAP partion: $swap"
  sgdisk -n 0:0:$swap -t 0:8200 -c 0:swap /dev/$device # swap partition
fi

echo -e "[${Cyan}*${White}] Creating Root Partition"
sgdisk -n 0:0:0 -t 0:8300 -c 0:root /dev/$device # root partition

# grabbing partition variables
for i in $(seq 1 10); do
  if [ $(lsblk -dno PARTLABEL /dev/$device$i) = boot ]; then
    boot_partition=$device$i
  elif [ $(lsblk -dno PARTLABEL /dev/$device$i) = swap ]; then
    swap_partition=$device$i
  elif [ $(lsblk -dno PARTLABEL /dev/$device$i) = root ]; then
    root_partition=$device$i
  fi
done

echo -e "[${Cyan}*${White}] Creating FAT32 filesystem for boot"
mkfs.fat -F 32 /dev/$boot_partition

echo -e "[${Cyan}*${White}] Creating BTRFS filesystem for root"
mkfs.btrfs /dev/$root_partition

if [ -z "$swap" ]; then
  echo -e "[${Cyan}*${White}] Not creating a SWAP partition, no need to mkswap"
else
  echo -e "[${Cyan}*${White}] Activating SWAP"
  mkswap /dev/$swap_partition
fi

echo -e "[${Cyan}*${White}] Mounting file system"
mount /dev/$root_partition /mnt

if [ -z "$swap" ]; then
  echo -e "[${Cyan}*${White}] Not creating a SWAP partition, no need to swapon"
else
  echo -e "[${Cyan}*${White}] Activating SWAP"
  swapon /dev/$swap_partition
fi

if [ $(cat /sys/firmware/efi/fw_platform_size) -eq 64 ]; then
  mount --mkdir /dev/$boot_partition /mnt/boot
elif [ $(cat /sys/firmware/efi/fw_platform_size) -eq 32 ]; then
  exit #TODO: 32 bit UEFI
else
  exit #TODO: BIOS + GRUB
fi

#################################
### Installation Dependencies ###
#################################

# Pacstrap minimal install packages
echo -e "[${Cyan}*${White}] Invoking pacstrap with minimal installation packages..."
for pkg in $(cat $package_lists_path"minimal"); do
  base_pkgs="$base_pkgs $pkg"
done
pacstrap -K /mnt $base_pkgs

# Generate Fstab file
echo -e "[${Cyan}*${White}] Generating Fstab file"
sudo genfstab -U /mnt >>/mnt/etc/fstab

# Chroot into the system
echo -e "[${Cyan}*${White}] Chroot-ing into the system..."
arch-chroot /mnt

# Start & Enable NetworkManager for internet
echo -e "[${Cyan}*${White}] Starting & Enabling NetworkManager Daemon"
systemctl start NetworkManager
systemctl enable NetworkManager

########################
### Install Packages ###
########################

# Add hardware packages to install list
echo -e "[${Cyan}*${White}] Adding hardware-specific packages to the install list"
amd_cpu_packages=(amd-ucode)
amd_gpu_packages=(rocm-opencl-runtime mesa lib32-mesa vulkan-radeon amdvlk lib32-vulkan-radeon lib32-amdvlk)
intel_cpu_packages=(intel-ucode)
intel_gpu_packages=(mesa)
nvidia_cpu_packages=()
nvidia_gpu_packages=(opencl-nvidia mesa lib32-mesa nvidia-utils vulkan-nouveau lib32-vulkan-nouveau)
if [ $system_cpu = amd ]; then
  echo "[${Cyan}*${White}] Detected AMD CPU"
  cpu_pkgs=("${amd_cpu_packages[@]}")
elif [ $system_cpu = intel ]; then
  echo "[${Cyan}*${White}] Detected Intel CPU"
  cpu_pkgs=("${intel_cpu_packages[@]}")
elif [ $system_cpu = nvidia ]; then
  echo "[${Cyan}*${White}] Detected NVidia CPU"
  cpu_pkgs=("${nvidia_cpu_packages[@]}")
else
  echo "[$Red*$White]$Red WARNING - CPU install setting not correctly set, not optimizing for CPU.$White"
fi
if [ $system_gpu = amd ]; then
  echo "[${Cyan}*${White}] Detected AMD GPU"
  gpu_pkgs=("${amd_gpu_packages[@]}")
elif [ $system_gpu = intel ]; then
  echo "[${Cyan}*${White}] Detected Intel GPU"
  gpu_pkgs=("${intel_gpu_packages[@]}")
elif [ $system_gpu = nvidia ]; then
  echo "[${Cyan}*${White}] Detected NVidia GPU"
  gpu_pkgs=("${nvidia_gpu_packages[@]}")
else
  echo "[$Red*$White]$Red WARNING - GPU install setting not correctly set, not optimizing for GPU.$White"
fi
for pkg in "${cpu_pkgs[@]}" "${gpu_pkgs[@]}"; do
  echo "$pkg" >>./packages/minimal
done

# Add options to install lists
if [ unity_install = y ]; then
  echo "unityhub" >>./packages/miscellanious
fi
if [ unreal_install = y ]; then
  echo "unreal-engine" >>./packages/miscellanious
fi
if [ godot_install = y ]; then
  echo "godot" >>./packages/miscellanious
fi
if [ godot_install = y-mono ]; then
  echo "godot-mono-bin" >>./packages/miscellanious
fi
if [ davinci_install = y ]; then
  echo "davinci-resolve" >>./packages/miscellanious
fi
if [ davinci_install = y-studio ]; then
  echo "davinci_resolve-studio" >>./packages/miscellanious
fi

# Install AUR package manager
echo -e "[${Cyan}*${White}] Installing AUR Package Manager - paru"
mkdir -pvm 777 $HOME/aur/
cd $HOME/aur/
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Update System before mass package-install
echo -e "[${Cyan}*${White}] Updating system..."
paru -Syu

# Install packages
echo -e "[${Cyan}*${White}] Installing Pacman + AUR Packages..."
for pkglist in "${pacman_lists[@]}"; do
  for pkg in $(cat $package_lists_path$pkglist); do
    echo -e "[${Red}*${White}] Installing $pkg..."
    paru -S --noconfirm "$pkg" | tee -a "$LOG"
    if [ $? -ne 0 ]; then
      echo -e "\e[1A\e[K${ERROR} - $pkg Package installation failed, Please check the installation logs"
      exit 1
    fi
  done
done
echo -e "[${Cyan}*${White}] Installing Flatpak Packages..."
for pkglist in "${flatpak_lists[@]}"; do
  for pkg in $(cat $package_lists_path$pkglist); do
    echo -e "[${Red}*${White}] Installing $pkg..."
    flatpak install --noninteractive "$pkg" | tee -a "$LOG"
    if [ $? -ne 0 ]; then
      echo -e "\e[1A\e[K${ERROR} - $pkg Flatpak package installation failed, Please check the installation logs"
      exit 1
    fi
  done
done

# Update Packages (Again)(Likely updates since starting if internet is slow)
echo -e "[${Cyan}*${White}] Updating packages..."
paru -Syu

######################
### Install Themes ###
######################

echo -e "[${Cyan}*${White}] Installing Theme, Icons, and Font..."

# Move those directories, whether they existed or not, to $HOME equivalent directores.
sudo mv -f /usr/share/themes $HOME/.themes
sudo mv -f /usr/share/icons $HOME/.icons
sudo mv -f $HOME/.icons $HOME/.local/share/icons

# Create a symlink between the new paths and old paths
sudo ln -s $HOME/.themes /usr/share/themes
sudo ln -s $HOME/.icons /usr/share/icons
sudo ln -s $HOME/.local/share/icons $HOME/.icons

# Set Flatpaks to have access to those directories, as well as the GTK4 themes in xdg-config.
flatpak override --user --filesystem=$HOME/.themes
flatpak override --user --filesystem=$HOME/.local/share/icons
flatpak override --user --filesystem=xdg-config/gtk-4.0

# Set the GTK Theme and GTK Icons for non-Flatpaks (everforest-gtk-theme-git from AUR)
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Everforest-Green-Dark

# Set the same for Flatpaks
flatpak override --user --env=GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
flatpak override --user --env=ICON_THEME=oomox-Everforest-Dark

# Set QT Flatpaks to use the currently active Kvantum theme
flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum --filesystem=xdg-config/Kvantum:ro

########################
### Configure System ###
########################

# Set the system time zone
echo -e "[${Cyan}*${White}] Setting System Time Zone"
sudo ln -sf /usr/share/zoneinfo/${system_clock_region}/${system_clock_city} /etc/localtime
timedatectl set-local-rtc 0                 #Use UTC
sudo echo LC_TIME=C.UTF-8 >/etc/locale.conf #Use 24-hour clock
sudo hwclock --systohc

# Locale & Keyboard layout
echo -e "[${Cyan}*${White}] Setting Locale & Keyboard Layout"
sudo echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
sudo echo "ja_JP.UTF-8 UTF-8" >>/etc/locale.gen
sudo locale-gen
sudo localectl set-keymap --no-convert ${system_keymap}
sudo echo "${system_keymap}" >/etc/vconsole.conf
sudo echo LANG=en_US.UTF-8 >>/etc/locale.conf

#########################
### HARDWARE SPECIFIC ###
#########################

# CPU
if [ $system_cpu = amd ]; then
  echo "[$Cyan*$White] CPU install setting set to AMD - Configuring hardware-specific stuff."
  hooks="base udev autodetect microcode modconf kms keyboard keymap consolefont numlock block filesystems fsck"
elif [ $system_cpu = intel ]; then
  echo "[$Cyan*$White] CPU install setting set to Intel - Configuring hardware-specific stuff."
  hooks="base udev autodetect microcode modconf kms keyboard keymap consolefont numlock block filesystems fsck"
elif [ $system_cpu = nvidia ]; then
  echo "[$Cyan*$White] CPU install setting set to Nvidia - Configuring hardware-specific stuff."
else
  echo "[$Red*$White]$Red WARNING - CPU install setting not correctly set, not optimizing for CPU.$White"
fi

################################
### POST MAIN INSTALL CONFIG ###
################################

# Set initramfs HOOKS
echo -e "[${Cyan}*${White}] Setting /etc/mkinitcpio.conf"
sudo echo "HOOKS=($hooks)" >>/etc/mkinitcpio.conf

# Create a user
echo -e "[${Cyan}*${White}] Creating starting user"
useradd -m -G wheel gamemode audio realtime -s /bin/bash $user_username
sudo echo "%wheel ALL=(ALL:ALL) ALL" >/etc/sudoers

# Create directories for bookmarking
xdg-user-dirs-update
mkdir -pvm 776 $HOME/Pictures/Screenshots/
mkdir -v 776 $HOME/Art/
mkdir -v 776 $HOME/Projects/
mkdir -v 776 $HOME/Applications/

# MIME
echo -e "[${Cyan}*${White}] Configuring MIMEs..."
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# Enable Misc. Daemons
echo -e "[${Cyan}*${White}] Enabling miscellanious daemons (sshd, dhcpcd, ntpd, fstrim.timer)..."
systemctl enable sshd         #SSH
systemctl enable dhcpcd       #DHCP
systemctl enable fstrim.timer #SSD Periodic (weekly) Trim
systemctl enable ntpd         #time syncing
timedatectl set-ntp true      #set ntp for time syncing

# Unmute ALSA
echo -e "[${Cyan}*${White}] Unmuting ALSA"
amixer sset Master unmute
amixer sset Speaker unmute
amixer sset Headphone unmute

# Increase vm.max_map_count (Game Compatibility)
# https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
echo -e "[${Cyan}*${White}] Increasing vm.max_map_count to 2147483642 for game compatibility"
sudo echo "vm.max_map_count = 2147483642" >/etc/systcl.d/80-gamecompatibility.conf

# Delay after failed login
echo -e "[${Cyan}*${White}] Adding fail delay to login"
sudo echo "auth optional pam_faildelay.so delay=4000000" >>/etc/pam.d/system-login

# Set the hostname for system's network
echo -e "[${Cyan}*${White}] Setting system's network hostname"
sudo echo ${system_hostname} >/etc/hostname

# Generate new initramfs
echo -e "[${Cyan}*${White}] Generating new initramfs..."
mkinitcpio -P

##############################
### Configure Applications ###
##############################

echo -e "[${Cyan}*${White}] Configuring Applications..."

# File Chooser
gsettings set org.gtk.Settings.FileChooser startup-mode cwd

# Kitty
sudo ln -s /usr/bin/kitty /usr/bin/gnome-terminal # Makes certain gnome apps work w/Kitty

# Nemo
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty

# Krita
flatpak override --user --env=KRITA_NO_STYLE_OVERRIDE=1 org.kde.krita

# Unreal Engine
if [ unreal_install = y ]; then
  chmod -R a+rwX /opt/unreal-engine/Engine
fi

echo -e "$Green[*] Installation Complete!$White"
echo -e "[${Cyan}*${White}] Please reboot the system..."
echo "$LOG"
exit 0

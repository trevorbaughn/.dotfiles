#!/bin/bash
# https://github.com/trevorbaughn/.dotfiles
# Execute curl -L https://raw.githubusercontent.com/trevorbaughn/.dotfiles/refs/heads/master/bin/installscripts/sysinstall.sh > sysinstall.sh && chmod +x sysinstall.sh && ./sysinstall.sh

# Script Colors
Red='\e[0;31m'
Green='\e[0;32m'
Cyan='\e[0;36m'
White='\e[0;00m'

# Logging
LOG="sysinstall-part1-$(date +%d-%H%M%S).log"

################################
### Install Option Questions ###
################################

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

echo -e "[${Cyan}*${White}] Is the system CPU; 'amd', 'nvidia', or 'intel'?"
echo -n "cpu: "
read -r system_cpu
echo -e "[${Cyan}*${White}] Is the system GPU; 'amd', 'nvidia', or 'intel'?"
echo -n "gpu: "
read -r system_gpu

echo -e "[${Cyan}*${White}] What will your admin user's username be?"
echo -n "username: "
read -r user_username

echo -e "[${Cyan}*${White}] What will your admin user's password be?"
echo -n "password: "
read -r user_password

echo -e "[${Cyan}*${White}] What will your root password be?"
echo -n "root password: "
read -r root_password

lsblk
echo -e "[${Cyan}*${White}] What drive would you like to install on? \
[${Red}WARNING${White}] ALL ORIGINAL DATA ON THE SELECTED DRIVE WILL BE LOST"
echo -n "/dev/"
read -r device

echo -e "[${Cyan}*${White}] How much SWAP memory do you wish to have? Leave blank for none. \
-- ex. '+8GiB' for 8 gigabytes \
[${Cyan}NOTE${White}] It is recommended to use an equal amount of SWAP as you have RAM for the hibernation feature."
echo -n "SWAP: "
read -r swap

ls /usr/share/kbd/consolefonts/
echo -e "[${Cyan}*${White}] What would you like to set the console font to?"
echo -n "Font: "
read -r font

echo -e "[${Cyan}*${White}] Would you like to install Unreal Engine 5? \
[${Cyan}NOTE${White}] It is recommended to ensure the root partition has enough space. \
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

echo -e "[${Cyan}*${White}] Press Enter to Start Installation..."
read -r dummy

#######################
### GENERAL INSTALL ###
#######################

# Set Font
setfont $font

# Partition, Format, & Mount drives
curl -L https://raw.githubusercontent.com/trevorbaughn/.dotfiles/refs/heads/master/bin/installscripts/auto-partition.sh > auto-partition.sh
chmod +x auto-partition.sh
./auto-partition.sh ${LOG} ${Cyan} ${White} ${Red} ${Green} ${device} ${swap}

# Pacstrap with minimal install packages
curl -L https://raw.githubusercontent.com/trevorbaughn/.dotfiles/refs/heads/master/bin/installscripts/packages/minimal > minimal
chmod +r minimal
echo -e "[${Cyan}*${White}] Invoking pacstrap with minimal installation packages..."
for pkg in $(cat "minimal"); do
  base_pkgs="$base_pkgs $pkg"
done
pacstrap -K /mnt $base_pkgs

# Generate Fstab file
echo -e "[${Cyan}*${White}] Generating Fstab file"
genfstab -U /mnt >>/mnt/etc/fstab

# Chroot into the system
echo -e "[${Cyan}*${White}] Chroot-ing into the system..."
arch-chroot /mnt /bin/bash <<EOF

# Start & Enable NetworkManager for internet
echo -e "[${Cyan}*${White}] Starting & Enabling NetworkManager Daemon"
systemctl start NetworkManager
systemctl enable NetworkManager

# Enable multilib for 32-bit support
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

# Set the system time zone and clock
echo -e "[${Cyan}*${White}] Setting System Time Zone and Clock"
ln -sf /usr/share/zoneinfo/${system_clock_region}/${system_clock_city} /etc/localtime
timedatectl set-local-rtc 0            #Use UTC
echo LC_TIME=C.UTF-8 >/etc/locale.conf #Use 24-hour clock
hwclock --systohc
systemctl enable ntpd    #Enable time sync daemon
timedatectl set-ntp true #Set ntp for time syncing

# Locale & Keyboard layout
echo -e "[${Cyan}*${White}] Setting Locale & Keyboard Layout"
echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
echo "ja_JP.UTF-8 UTF-8" >>/etc/locale.gen
locale-gen
localectl set-keymap --no-convert ${system_keymap}
echo "${system_keymap}" >/etc/vconsole.conf
echo LANG=en_US.UTF-8 >>/etc/locale.conf

# Set Root Password
echo -e "[${Cyan}*${White}] Setting Root Password"
echo "root:${root_password}" | chpasswd -e

# Create a user and set their password
echo -e "[${Cyan}*${White}] Creating starting admin user"
useradd -m -G wheel,gamemode,audio,realtime -s /bin/bash $user_username
echo "${user_username}:${user_password}" | chpasswd -e

# Delay after failed login
echo -e "[${Cyan}*${White}] Adding delay to failed login"
sudo echo "auth optional pam_faildelay.so delay=4000000" >>/etc/pam.d/system-login

# All users in wheel group are sudoers
echo -e "[${Cyan}*${White}] Setting 'wheel' group to sudoers"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Set the hostname for system's network
echo -e "[${Cyan}*${White}] Setting system's network hostname"
echo ${system_hostname} >/etc/hostname

echo -e "[${Cyan}*${White}] Press Enter to Continue..."
read -r dummyagain

# Clone repo
# Bare repo method: https://www.atlassian.com/git/tutorials/dotfiles
#git clone --bare https://github.com/trevorbaughn/.dotfiles.git $HOME/.dotfiles
#function dotfiles {
#   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
#}
#mkdir -p .dotfiles-backup
#dotfiles checkout
#if [ $? = 0 ]; then
#  echo "Checked out dotfiles.";
#  else
#    echo "Backing up pre-existing dotfiles.";
#    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
#fi;
#dotfiles checkout
#dotfiles config status.showUntrackedFiles no

echo -e "[${Cyan}*${White}] Press Enter to Continue..."
read -r anddummyyetagain

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

echo -e "[${Cyan}*${White}] Setting /etc/mkinitcpio.conf modules"
sed -i "/^MODULES=/ c\MODULES=($modules)" /etc/mkinitcpio.conf

echo -e "[${Cyan}*${White}] Setting /etc/mkinitcpio.conf hooks"
sed -i "/^HOOKS=/ c\HOOKS=($hooks)" /etc/mkinitcpio.conf

#cat /etc/mkinitcpio.conf
echo $hooks

echo -e "[${Cyan}*${White}] Generating new initramfs..."
mkinitcpio -P

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB  
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable grub-btrfsd

systemctl enable sddm

echo -e "[${Cyan}*${White}] Setting up autostart for next part of script after reboot..."
echo "chmod +x $HOME/bin/installscripts/sysinstall-part2.sh && bash $HOME/bin/installscripts/sysinstall-part2.sh" >>$HOME/.bashrc

echo "[$Cyan*$White] Printing Install Log -"
echo "$LOG" > "sysinstall-part1-$(date +%d-%H%M%S).log"


#echo variables to be picked up later
echo "${Cyan}" >"${HOME}/bin/installscripts/install-variables"
echo "${White}" >"${HOME}/bin/installscripts/install-variables"
echo "${Red}" >"${HOME}/bin/installscripts/install-variables"
echo "${system_cpu}" >"${HOME}/bin/installscripts/install-variables"
echo "${system_gpu}" >"${HOME}/bin/installscripts/install-variables"
echo "${unity_install}" >"${HOME}/bin/installscripts/install-variables"
echo "${unreal_install}" >"${HOME}/bin/installscripts/install-variables"
echo "${godot_install}" >"${HOME}/bin/installscripts/install-variables"
echo "${davinci_install}" >"${HOME}/bin/installscripts/install-variables"

EOF

echo -e "$Green[*] Installation Part 1 Complete!$White"
echo -e "[${Cyan}*${White}] Please reboot the system..."
echo -e "[${Cyan}*${White}] Press Enter to Reboot..."
read -r dummy

# Unmount all partitions and reboot
umount -R /mnt
reboot

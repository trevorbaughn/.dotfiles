# Passed-in variables
LOG=$0
Cyan=$1
White=$2
Red=$3
system_cpu=$4
system_gpu=$5
unity_install=$6
unreal_install=$7
godot_install=$8
davinci_install=$9

# Non-passed-in variables
package_lists_path=$HOME/bin/installscripts/packages/
flatpak_lists=(end-user-flatpaks flatpak-runtimes-and-compatibility)
pacman_lists=(minimal cli-tools audio fonts themes programming-languages desktop-environment hardware-specific)

#Ignore history for commands that need password piped in
export HISTIGNORE='*sudo -S*'
sudopass="echo '$root_password' | sudo -S -v"

# Add hardware packages to install list
echo -e "[${Cyan}*${White}] Adding hardware-specific packages to the install list"
amd_cpu_packages=(amd-ucode)
amd_gpu_packages=(rocm-opencl-runtime mesa lib32-mesa vulkan-radeon amdvlk lib32-vulkan-radeon lib32-amdvlk)
intel_cpu_packages=(intel-ucode)
intel_gpu_packages=(mesa)
nvidia_cpu_packages=()
nvidia_gpu_packages=(opencl-nvidia mesa lib32-mesa nvidia-utils vulkan-nouveau lib32-vulkan-nouveau)

if [ "$system_cpu" = "amd" ]; then
  echo -e "[${Cyan}*${White}] Adding AMD CPU Packages to install list"
  cpu_pkgs=("${amd_cpu_packages[@]}")
elif [ "$system_cpu" = "intel" ]; then
  echo -e "[${Cyan}*${White}] Adding Intel CPU Packages to install list"
  cpu_pkgs=("${intel_cpu_packages[@]}")
elif [ "$system_cpu" = "nvidia" ]; then
  echo -e "[${Cyan}*${White}] Adding NVidia CPU Packages to install list"
  cpu_pkgs=("${nvidia_cpu_packages[@]}")
else
  echo -e "[${Red}WARNING${White}]${Red} CPU install setting not correctly set, not optimizing for CPU.${White}"
fi
if [ "$system_gpu" = "amd" ]; then
  echo -e "[${Cyan}*${White}] Adding AMD GPU Packages to install list"
  gpu_pkgs=("${amd_gpu_packages[@]}")
elif [ "$system_gpu" = "intel" ]; then
  echo -e "[${Cyan}*${White} Adding Intel GPU Packages to install list"
  gpu_pkgs=("${intel_gpu_packages[@]}")
elif [ "$system_gpu" = "nvidia" ]; then
  echo -e "[${Cyan}*${White}] Adding NVidia GPU Packages to install list"
  gpu_pkgs=("${nvidia_gpu_packages[@]}")
else
  echo -e "[${Red}WARNING${White}]${Red} GPU install setting not correctly set, not optimizing for GPU.${White}"
fi
for pkg in "${cpu_pkgs[@]}" "${gpu_pkgs[@]}"; do
  echo "$pkg" >>./packages/hardware-specific
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

# Enable multilib for 32-bit support
echo -e "[${Cyan}*${White}] Enabling multilib for 32-bit support"
$($sudopass -i sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf)

# Update System before mass package-install
echo -e "[${Cyan}*${White}] Updating system..."
sudopass -i pacman -Syu

# Install AUR package manager
echo -e "[${Cyan}*${White}] Installing AUR Package Manager - paru"
mkdir -pvm 777 $HOME/aur/
cd $HOME/aur/
sudopass -i pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd $HOME/aur/paru
makepkg -si

# Install packages
echo -e "[${Cyan}*${White}] Installing Pacman + AUR Packages..."
for pkglist in "${pacman_lists[@]}"; do
  for pkg in $(cat $package_lists_path$pkglist); do
    echo -e "[${Cyan}*${White}] Installing $pkg..."
    paru -S --noconfirm "$pkg" | tee -a "$LOG"
    if [ $? -ne 0 ]; then
      echo -e "${Red}[${ERROR}] $pkg Package installation failed, Please check the installation logs${White}"
      echo -e "$pkg - Installation Failed." >> "$LOG"
      #exit 1
    fi
  done
done
echo -e "[${Cyan}*${White}] Installing Flatpak Packages..."
for pkglist in "${flatpak_lists[@]}"; do
  for pkg in $(cat $package_lists_path$pkglist); do
    echo -e "[${Cyan}*${White}] Installing $pkg..."
    flatpak install --noninteractive "$pkg" | tee -a "$LOG"
    if [ $? -ne 0 ]; then
      echo -e "${Red}[${ERROR}] $pkg Flatpak package installation failed, Please check the installation logs${White}"
      echo -e "$pkg - Installation Failed." >> "$LOG"
      #exit 1
    fi
  done
done

# Update Packages (Again)(Likely updates since starting if internet is slow)
echo -e "[${Cyan}*${White}] Updating packages..."
sudopass paru -Syu

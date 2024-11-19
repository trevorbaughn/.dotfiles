# Passed-in variables
LOG=$1
Cyan=$2
White=$3
Red=$4
Green=$5
device=$6
swap=$7

# Format drive and wipe filesystems
sgdisk -Z /dev/$device
wipefs -a /dev/$device*

# Create Partitions
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
for i in $(seq 1 3); do
  if [ "$(lsblk -dno PARTLABEL /dev/$device$i)" = "boot" ]; then
    boot_partition=$device$i
  elif [ "$(lsblk -dno PARTLABEL /dev/$device$i)" = "swap" ]; then
    swap_partition=$device$i
  elif [ "$(lsblk -dno PARTLABEL /dev/$device$i)" = "root" ]; then
    root_partition=$device$i
  fi
done

echo -e "[${Cyan}*${White}] Creating FAT32 filesystem for boot"
mkfs.fat -F32 /dev/$boot_partition

echo -e "[${Cyan}*${White}] Creating BTRFS filesystem for root"
mkfs.btrfs -f /dev/$root_partition

if [ -z "$swap" ]; then
  echo -e "[${Cyan}*${White}] Not creating a SWAP partition, no need to mkswap"
else
  echo -e "[${Cyan}*${White}] Activating SWAP"
  mkswap /dev/$swap_partition
fi

echo -e "[${Cyan}*${White}] Mounting root file system and creating btrfs subvolumes"
mount /dev/$root_partition /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

echo -e "[${Cyan}*${White}] Unmounting root and remounting as btrfs subvolumes"
umount /mnt
mkdir -p /mnt/{boot,home,.snapshots}
mount -o noatime,space_cache=v2,compress=zstd,subvol=@ /dev/$root_partition /mnt
mount -o noatime,space_cache=v2,compress=zstd,subvol=@home /dev/$root_partition /mnt/home
mount -o noatime,space_cache=v2,compress=zstd,subvol=@snapshots /dev/$root_partition /mnt/.snapshots

if [ -z "$swap" ]; then
  echo -e "[${Cyan}*${White}] Not creating a SWAP partition, no need to swapon"
else
  echo -e "[${Cyan}*${White}] Activating SWAP"
  swapon /dev/$swap_partition
fi

if [ $(cat /sys/firmware/efi/fw_platform_size) -eq 64 ]; then
  mount --mkdir /dev/$boot_partition /mnt/efi
elif [ $(cat /sys/firmware/efi/fw_platform_size) -eq 32 ]; then
  exit 1 #TODO: 32 bit UEFI
else
  exit 1 #TODO: BIOS + GRUB
fi

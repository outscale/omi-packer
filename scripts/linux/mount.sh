#!/bin/bash
set -e

# MAKE SURE EVERY PARTITION IS PICKED UP AND UPDATED
partprobe
echo 1 > /sys/block/sda/device/rescan
sleep 2

# Get the biggest partition of /dev/sda as root partition
root_partition=$(fdisk -lo device,size /dev/sda | grep -E '^\/dev\/' | tr -s ' ' | sort -rhk2 | head -n1 | cut -d ' ' -f1)

if [[ "$1" == "centos"* ]] || [[ "$1" == "rocky"* ]] || [[ "$1" == "alma"* ]] || [[ "$1" == "rhel"* ]]; then
    mount -o nouuid $root_partition /mnt
else
    mount $root_partition /mnt
fi

mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

if [[ "$1" == "debian"* ]]; then
    # Get EFI partition
    efi_partition=$(fdisk -lo device,type /dev/sda | grep -E '^\/dev\/' | tr -s ' ' | grep -E 'EFI' | head -n1 | cut -d ' ' -f1)
    mkdir -p /mnt/boot/efi
    mount $efi_partition /mnt/boot/efi
fi

if [[ "$1" == "ubuntu24"* ]]; then
    # Get Extended Linux partition for boot/grub
    ext_partition=$(fdisk -lo device,type /dev/sda | grep -E '^\/dev\/' | tr -s ' ' | grep -E 'extended' | head -n1 | cut -d ' ' -f1)
    mkdir -p /mnt/boot
    mount $ext_partition /mnt/boot
fi
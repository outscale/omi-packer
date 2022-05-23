#!/bin/bash
set -e

# MAKE SURE EVERY PARTITION IS PICKED UP AND UPDATED
partprobe
echo 1 > /sys/block/sda/device/rescan
sleep 2

if [[ "$1" == "centos"* ]] || [[ "$1" == "rocky"* ]]; then
    mount -o nouuid /dev/sda1 /mnt
elif [[ "$1" == "rhel8"* ]]; then
    mount -o nouuid /dev/sda3 /mnt
elif [[ "$1" == "rhel9"* ]]; then
    mount -o nouuid /dev/sda4 /mnt
elif [[ "$1" == "arch" ]]; then
    mount /dev/sda2 /mnt
else
    mount /dev/sda1 /mnt
fi

mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

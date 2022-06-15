#!/bin/bash
set -e

# MAKE SURE EVERY PARTITION IS PICKED UP AND UPDATED
partprobe
echo 1 > /sys/block/sda/device/rescan
sleep 2

if [[ "$1" == "centos"* ]] || [[ "$1" == "rocky"* ]] || [[ "$1" == "rhel"* ]]; then
    mount -o nouuid /dev/sda$(grep -c 'sda[0-9]' /proc/partitions) /mnt
else
    mount /dev/sda$(grep -c 'sda[0-9]' /proc/partitions) /mnt
fi

mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

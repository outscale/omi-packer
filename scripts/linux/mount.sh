#!/bin/bash
set -e

# MAKE SURE EVERY PARTITION IS PICKED UP AND UPDATED
partprobe
echo 1 > /sys/block/sda/device/rescan
sleep 2

if [[ "$1" == "centos"* ]] || [[ "$1" == "rhel"* ]]; then
    # IN CASE UPSTREAM PARTITION HAS SAME UUID AS HOST
    mount -o nouuid /dev/sda1 /mnt
else
    mount /dev/sda1 /mnt
fi

mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

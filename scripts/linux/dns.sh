#!/bin/bash
set -e

if [[ "$1" == "debian"* ]] || [[ "$1" == "ubuntu"* ]]; then
    # SYSTEMD-RESOLVED EMULATION
    mount -o bind /run /mnt/run
    mkdir -p /run/resolvconf/
    cp /etc/resolv.conf /run/resolvconf/resolv.conf
    chroot /mnt/ bash -c '[[ -f /etc/resolv.conf ]]'
else
    cp /etc/resolv.conf /mnt/etc/resolv.conf
fi

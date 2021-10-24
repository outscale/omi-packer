#!/bin/bash
set -e

if [[ "$1" == "debian"* ]] || [[ "$1" == "ubuntu"* ]] || [[ "$1" == "arch" ]]; then
    # SYSTEMD-RESOLVED EMULATION
    mount -o bind /run /mnt/run
    mkdir -p /run/resolvconf/
    mkdir -p /run/systemd/resolve/
    cp /etc/resolv.conf /run/resolvconf/resolv.conf
    cp /etc/resolv.conf /run/systemd/resolve/stub-resolv.conf
    chroot /mnt/ bash -c '[[ -f /etc/resolv.conf ]]'
else
    cp /etc/resolv.conf /mnt/etc/resolv.conf
fi

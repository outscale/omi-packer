#!/bin/bash
set -e

if [[ "$1" == "debian12" ]] || [[ "$1" == "ubuntu24"* ]]; then
    chroot /mnt/ apt install net-tools -y
fi

# Netplan file permission fix OMI-239
#if [[ "$1" == "debian12" ]]; then
#    chmod 644 /mnt/etc/netplan/50-cloud-init.yaml
#fi

#!/bin/bash
set -e

if [[ "$1" == "debian12" ]]; then
    chroot /mnt/ apt update -y
    chroot /mnt/ apt install chrony -y
fi

# make executable chronyd script fix OMI-239
if [[ "$1" == "debian12" ]]; then
    chmod +x /mnt/etc/dhcp/dhclient-exit-hooks.d/chrony
fi

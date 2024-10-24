#!/bin/bash
set -e

if [[ "$1" == "debian12" ]]; then
    chroot /mnt/ apt update -y
    chroot /mnt/ apt install chrony -y
fi

# chronyd dhcp sync fix OMI-239
if [[ "$1" == "debian12" ]]; then
    chmod +x /mnt/etc/dhcp/dhclient-exit-hooks.d/chrony
    cp /tmp/chrony-specific/10-dhcp-chrony /mnt/etc/NetworkManager/dispatcher.d/
    chmod +x /mnt/etc/NetworkManager/dispatcher.d/10-dhcp-chrony
fi

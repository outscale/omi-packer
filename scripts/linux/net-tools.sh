#!/bin/bash
set -e

if [[ "$1" == "debian12" ]]; then
    chroot /mnt/ apt install net-tools -y
fi

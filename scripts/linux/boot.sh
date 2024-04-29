#!/bin/bash
set -e

if [[ "$1" == "ubuntu20"* ]] || [[ "$1" == "ubuntu22"* ]] || [[ "$1" == "ubuntu24"* ]]; then
    # Fix for network interfaces not picked up
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="acpi_irq_isa=10 net.ifnames=0"/g' /mnt/etc/default/grub
    if [[ "$1" == "ubuntu24"* ]]; then
      chroot /mnt/ mkdir -p /boot/grub
    fi
    chroot /mnt/ update-grub
fi

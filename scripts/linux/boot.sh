#!/bin/bash
set -e

if [[ "$1" == "ubuntu20"* ]]; then
    # Fix for network interfaces not picked up
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="acpi_irq_isa=10"/g' /mnt/etc/default/grub
    chroot /mnt/ update-grub
fi

#!/bin/bash
set -e

#enable by default on debian/ubuntu/opensuse
if [[ "$1" == "centos"* ]] || [[ "$1" == "rocky"* ]] || [[ "$1" == "alma"* ]] || [[ "$1" == "rhel"* ]] || [[ "$1" == "arch"* ]]; then
    #Execute fstrim weekly
    chroot /mnt/ systemctl enable fstrim.timer
fi

#!/bin/bash
set -e

if [[ "$1" == "debian"* ]] || [[ "$1" == "ubuntu"* ]]; then
    #### UPDATES
    chroot /mnt/ apt update -y
    chroot /mnt/ apt install unattended-upgrade  -y
    chroot /mnt/ unattended-upgrade
    chroot /mnt/ apt clean

    #### OUTSCALE PACKAGES
    wget https://oos.eu-west-2.outscale.com/omi/packages/osc-udev-rules-20190314_amd64.deb -P /mnt/tmp
    chroot /mnt/ dpkg -i /tmp/osc-udev-rules-20190314_amd64.deb

    #### PACKAGE LIST
    chroot /mnt/ apt list --installed > /tmp/packages

elif [[ "$1" == "centos"* ]] || [[ "$1" == "rhel"* ]] || [[ "$1" == "rocky"* ]] || [[ "$1" == "alma"* ]]; then
    if [[ "$1" == "centos"* ]] || [[ "$1" == "rocky"* ]] || [[ "$1" == "alma"* ]]; then
        #### UPDATES
        chroot /mnt/ yum upgrade -y --security --secseverity=Critical
        chroot /mnt/ yum clean all
    fi

    #### OUTSCALE PACKAGES
    chroot /mnt yum install -y https://oos.eu-west-2.outscale.com/omi/packages/osc-udev-rules-20160519-1.x86_64.rpm

    #### PACKAGE LIST
    date > /tmp/packages
    chroot /mnt yum list installed > /tmp/packages

elif [[ "$1" == "arch" ]]; then
    chroot /mnt pacman-key --init
    chroot /mnt pacman-key --populate archlinux
    chroot /mnt pacman -Syu --noconfirm
    wget https://oos.eu-west-2.outscale.com/omi/packages/osc-udev-storage-2.0-1-any.pkg.tar.zst -P /mnt/tmp
    chroot /mnt pacman -U --noconfirm /tmp/osc-udev-storage-2.0-1-any.pkg.tar.zst
    chroot /mnt pacman -Q > /tmp/packages
    rm -rf /mnt/etc/pacman.d/gnupg

else
    touch /tmp/packages

fi

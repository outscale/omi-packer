#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget
cd /tmp
wget -q https://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.raw
wget -q https://cdimage.debian.org/cdimage/openstack/current-10/MD5SUMS
if [[ $(cat MD5SUMS | grep -c `md5sum *.raw | cut -c -32`) < 1 ]]; then exit 1; fi
mv *.raw debian10.raw
dd if=./debian10.raw of=/dev/sda bs=1G status=progress conv=sparse
mount /dev/sda1 /mnt

#### CHROOT FIXES
cp /etc/resolv.conf /mnt/etc/resolv.conf
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

#### UPDATES
chroot /mnt/ apt update -y
chroot /mnt/ apt upgrade -y
chroot /mnt/ apt clean

#### OUTSCALE PACKAGES
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20190314_amd64.deb -P /mnt/tmp
chroot /mnt/ dpkg -i /tmp/osc-udev-rules-20190314_amd64.deb
yes | cp -i /tmp/cloud.cfg /mnt/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config /mnt/etc/ssh/sshd_config
rm -f /mnt/etc/cloud/cloud.cfg.d/90_dpkg.cfg
chroot /mnt/ apt list --installed > /tmp/packages

#### CLEANUP
rm -f /mnt/etc/resolv.conf
rm -rf /mnt/var/cache/apt/*
rm -rf /mnt/root/.ssh
rm -rf /mnt/root/.bash_history
rm -rf /mnt/tmp/*
rm -rf /mnt/var/lib/dhcp/*
rm -rf /mnt/var/tmp/*
rm -rf /mnt/var/log/*
rm -rf /mnt/var/lib/cloud/*

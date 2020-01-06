#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget
cd /tmp
wget -q https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.raw
wget -q https://cdimage.debian.org/cdimage/openstack/current-9/MD5SUMS
if [[ $(cat MD5SUMS | grep -c `md5sum *.raw | cut -c -32`) < 1 ]]; then exit 1; fi
mv *.raw debian9.raw
dd if=./debian9.raw of=/dev/sda bs=1G status=progress conv=sparse
mount /dev/sda1 /mnt

#### CHROOT FIXES
cp /etc/resolv.conf /mnt/etc/resolv.conf
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

#### REMOVE DEFAULT USER
chroot /mnt/ userdel -r -f debian

#### UPDATES
chroot /mnt/ apt update -y
chroot /mnt/ apt upgrade -y
chroot /mnt/ apt clean

#### DIVERT SOURCE CONFIGURATION FILES
chroot /mnt/ dpkg-divert --local --divert /etc/cloud/cloud.cfg.default --rename /etc/cloud/cloud.cfg
chroot /mnt/ dpkg-divert --local --divert /etc/ssh/sshd_config --rename /etc/ssh/sshd_config.default

#### OUTSCALE PACKAGES
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20190314_amd64.deb -P /mnt/tmp
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/fni/osc-fni-1.0.1.noarch.deb -P /mnt/tmp
chroot /mnt/ dpkg -i /tmp/osc-udev-rules-20190314_amd64.deb
chroot /mnt/ dpkg -i /tmp/osc-fni-1.0.1.noarch.deb
yes | cp -i /tmp/cloud.cfg /mnt/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config /mnt/etc/ssh/sshd_config
rm -f /mnt/etc/cloud/cloud.cfg.d/90_dpkg.cfg

chroot /mnt/ apt list --installed > /tmp/packages

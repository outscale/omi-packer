#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img
cd /tmp
wget -q http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
wget -q https://cloud-images.ubuntu.com/xenial/current/MD5SUMS
if [[ $(md5sum -c MD5SUMS 2>&1 | grep -c OK) < 1 ]]; then exit 1; fi
mv *.img xenial.img
qemu-img convert ./xenial.img -O raw /dev/sda
partprobe /dev/sda
mount /dev/sda1 /mnt

#### CHROOT FIXES
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys
mv /mnt/etc/resolv.conf{,.bak}
cp /etc/resolv.conf /mnt/etc/resolv.conf

#### UPDATES
chroot /mnt/ apt update -y
chroot /mnt/ apt upgrade -y
chroot /mnt/ apt clean

#### OUTSCALE PACKAGES
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20190314_amd64.deb -P /mnt/tmp
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/fni/osc-fni-1.0.1.noarch.deb -P /mnt/tmp
chroot /mnt/ dpkg -i /tmp/osc-udev-rules-20190314_amd64.deb
chroot /mnt/ dpkg -i /tmp/osc-fni-1.0.1.noarch.deb
yes | cp -i /tmp/cloud.cfg /mnt/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config /mnt/etc/ssh/sshd_config
chroot /mnt/ apt list --installed > /tmp/packages

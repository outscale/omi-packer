#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img sg3_utils
cd /tmp
wget -q http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
wget -q https://cloud-images.ubuntu.com/bionic/current/MD5SUMS
if [[ $(md5sum -c MD5SUMS 2>&1 | grep -c OK) < 1 ]]; then exit 1; fi
mv *.img bionic.img
qemu-img convert ./bionic.img -O raw /dev/sda
rescan-scsi-bus.sh -a
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

#### CONFIGURATION
#### OUTSCALE PACKAGES
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20190314_amd64.deb -P /mnt/tmp
#wget https://osu.eu-west-2.outscale.com/outscale-official-packages/fni/osc-fni-2.0.x86_64.deb -P /mnt/tmp
chroot /mnt/ dpkg -i /tmp/osc-udev-rules-20190314_amd64.deb
#chroot /mnt/ dpkg -i /tmp/osc-fni-2.0.x86_64.deb
yes | cp -i /tmp/cloud.cfg /mnt/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config /mnt/etc/ssh/sshd_config
chroot /mnt/ apt list --installed > /tmp/packages

#### CLEANUP
rm -f /mnt/etc/resolv.conf
mv /mnt/etc/resolv.conf.bak /mnt/etc/resolv.conf
rm -rf /mnt/var/cache/apt
rm -rf /mnt/root/.ssh
rm -rf /mnt/root/.bash_history
rm -rf /mnt/var/lib/dhcp/
rm -rf /mnt/var/tmp/*
rm -rf /mnt/var/log/*
rm -rf /mnt/var/lib/cloud/*

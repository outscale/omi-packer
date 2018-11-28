#!/bin/bash

#### BASIC IMAGE
yum install -y wget qemu-img
cd /tmp
wget -q http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
mv *.img bionic.img
qemu-img convert ./bionic.img -O raw bionic.raw
dd if=./bionic.raw of=/dev/sda bs=1G conv=sparse
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
## GRUB
echo 'GRUB_CMDLINE_LINUX="max_loop=256 net.ifnames=0 biosdevname=0 divider=10 notsc console=tty0 console=ttyS0,115200n8 elevator=deadline LANG=en_US.UTF-8 KEYTABLE=us nouveau.modeset=0"' >>/mnt/etc/default/grub
chroot /mnt/ update-grub

#### OUTSCALE PACKAGES
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules_20160516_amd64.deb -P /mnt/tmp
chroot /mnt/ dpkg -i /tmp/osc-udev-rules_20160516_amd64.deb
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/fni/osc-fni-1.0.0-x86_64.deb -P /mnt/tmp
chroot /mnt/ dpkg -i /tmp/osc-fni-1.0.0-x86_64.deb
yes | cp -i /tmp/cloud.cfg /mnt/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config /mnt/etc/ssh/sshd_config
yes | cp -i /tmp/blacklist-nouveau.conf /etc/modprobe.d/blacklist-nouveau.conf

#### CLEANUP
rm -f /mnt/etc/resolv.conf
mv /mnt/etc/resolv.conf.bak /mnt/etc/resolv.conf
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys
rm -rf /mnt/var/cache/apt
rm -rf /mnt/root/.ssh
rm -rf /mnt/root/.bash_history
rm -rf /mnt/home/ubuntu/.ssh
rm -rf /mnt/home/ubuntu/.bash_history
rm -rf /mnt/tmp/*
rm -rf /mnt/var/lib/dhcp/
rm -rf /mnt/var/tmp/*
rm -rf /mnt/var/log/*
rm -rf /mnt/var/lib/cloud/*
sleep 5
umount /mnt

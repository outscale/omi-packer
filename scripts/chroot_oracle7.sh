#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img
cd /tmp
wget -q "https://osu.eu-west-2.outscale.com/omi-packer-official/OracleLinux-7.6-x86_64.qcow2"
mv Oracle* oracle.qcow2
qemu-img convert ./oracle.qcow2 -O raw /dev/sda
partprobe /dev/sda
sleep 5
mount /dev/sda2 /mnt

#### CHROOT FIXES
cp /etc/resolv.conf /mnt/etc/resolv.conf
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

#### UPDATES
chroot /mnt/ yum upgrade -y
chroot /mnt/ yum clean all

#### OUTSCALE PACKAGES
chroot /mnt/ yum install -y http://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20160516-1.x86_64.rpm
chroot /mnt/ yum install -y http://osu.eu-west-2.outscale.com/outscale-official-packages/dhclient-configuration/dhclient-configuration-1.0.0-1-Centos7.x86_64.rpm
chroot /mnt/ yum install -y https://osu.eu-west-2.outscale.com/outscale-official-packages/fni/osc-fni-2.0-1.x86_64.rpm
yes | cp -i /tmp/cloud.cfg /mnt/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config_centos /mnt/etc/ssh/sshd_config
chroot /mnt/ yum list installed > /tmp/packages

#### CONFIGURATION
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /mnt/etc/selinux/config

#### CLEANUP
rm -f /mnt/etc/root/resolv.conf
rm -rf /mnt/var/cache/yum
rm -rf /mnt/.ssh
rm -rf /mnt/.bash_history
rm -rf /mnt/tmp/*
rm -rf /mnt/var/lib/dhcp/
rm -rf /mnt/var/tmp/*
rm -rf /mnt/var/log/*
rm -rf /mnt/var/lib/cloud/*

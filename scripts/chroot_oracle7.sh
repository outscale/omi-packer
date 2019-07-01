#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img
cd /tmp
wget -q "http://omi-packer.osu.eu-west-2.outscale.com/oracle/OracleLinux-7.4-x86_64.qcow2?AWSAccessKeyId=MTXAS23YQ67OUWJWJR3C&Expires=1569495828&Signature=pkqLTZ9oWBrZYIHEyMKuXeguyyk%3D"
mv Oracle* oracle.qcow2
qemu-img convert ./oracle.qcow2 -O raw /dev/sda
partprobe /dev/sda
sleep 5
mount /dev/sda2 /mnt

#### CHROOT FIXES
cp /etc/resolv.conf /mnt/root/etc/resolv.conf
mount -o bind /dev /mnt/root/dev
mount -o bind /proc /mnt/root/proc
mount -o bind /sys /mnt/root/sys

#### UPDATES
chroot /mnt/root/ yum upgrade -y
chroot /mnt/root/ yum clean all

#### OUTSCALE PACKAGES
chroot /mnt/root/ yum install -y http://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20160516-1.x86_64.rpm
chroot /mnt/root/ yum install -y http://osu.eu-west-2.outscale.com/outscale-official-packages/dhclient-configuration/dhclient-configuration-1.0.0-1-Centos7.x86_64.rpm
chroot /mnt/root/ yum install -y https://osu.eu-west-2.outscale.com/outscale-official-packages/fni/osc-fni-1.2.1-1.x86_64.rpm
yes | cp -i /tmp/cloud.cfg /mnt/root/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config_centos /mnt/root/etc/ssh/sshd_config
chroot /mnt/root/ yum list installed > /tmp/packages

#### CONFIGURATION
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /mnt/root/etc/selinux/config

#### CLEANUP
rm -f /mnt/root/etc/root/resolv.conf
rm -rf /mnt/var/cache/yum
rm -rf /mnt/root/.ssh
rm -rf /mnt/root/.bash_history
rm -rf /mnt/tmp/*
rm -rf /mnt/var/lib/dhcp/
rm -rf /mnt/var/tmp/*
rm -rf /mnt/var/log/*
rm -rf /mnt/var/lib/cloud/*

#!/bin/bash

#### BASIC IMAGE
yum install -y wget qemu-img
cd /tmp
wget http://omi-packer.osu.eu-west-2.outscale.com/oracle/OracleLinux-7.4-x86_64.qcow2?AWSAccessKeyId=MTXAS23YQ67OUWJWJR3C&Expires=1569495828&Signature=pkqLTZ9oWBrZYIHEyMKuXeguyyk%3D
mv *.qcow2 oracle.qcow2
qemu-img convert ./oracle.qcow2 -O raw oracle.raw
dd if=./oracle.raw of=/dev/sda bs=1G status=progress conv=sparse
mount -o nouuid /dev/sda2 /mnt

#### CHROOT FIXES
mount -o bind /dev /mnt/root/dev
mount -o bind /proc /mnt/root/proc
mount -o bind /sys /mnt/root/sys
mv /mnt/root/etc/resolv.conf{,.bak}
cp /etc/resolv.conf /mnt/root/etc/resolv.conf

#### UPDATES
chroot /mnt/root/ yum upgrade -y
chroot /mnt/root/ yum clean all

#### OUTSCALE PACKAGES
chroot /mnt/root/ rpm -i http://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20160516-1.x86_64.rpm
chroot /mnt/root/ rpm -i http://osu.eu-west-2.outscale.com/outscale-official-packages/dhclient-configuration/dhclient-configuration-1.0.0-1-Centos7.x86_64.rpm
chroot /mnt/root/ rpm -i http://osu.eu-west-2.outscale.com/outscale-official-packages/fni/osc-fni-1.0.0-8.x86_64.rpm

#### CONFIGURATION
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /mnt/root/etc/selinux/config

#### CLEANUP
rm -f /mnt/etc/root/resolv.conf
mv /mnt/etc/root/resolv.conf.bak /mnt/etc/root/resolv.conf
umount /mnt/root/dev
umount /mnt/root/proc
umount /mnt/root/sys
umount /mnt
rm -rf /mnt/var/cache/yum
rm -rf /mnt/root/.ssh
rm -rf /mnt/root/.bash_history
rm -rf /mnt/tmp/*
rm -rf /mnt/var/lib/dhcp/
rm -rf /mnt/var/tmp/*
rm -rf /mnt/var/log/*
rm -rf /mnt/var/lib/cloud/*

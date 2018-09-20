#!/bin/bash

#### BASIC IMAGE
yum install -y wget
cd /tmp
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.raw.tar.gz
tar -zxvf CentOS-7-x86_64-GenericCloud.raw.tar.gz && mv *.raw centos7.raw
dd if=./centos7.raw of=/dev/xvdf bs=1G status=progress conv=sparse
mount -o nouuid /dev/xvdf1 /mnt

#### CHROOT FIXES
cp /etc/resolv.conf /mnt/etc/resolv.conf
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

#### UPDATES
chroot /mnt/ yum upgrade -y
chroot /mnt/ yum clean all

#### OUTSCALE PACKAGES
chroot /mnt rpm -i http://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20160516-1.x86_64.rpm
chroot /mnt rpm -i http://osu.eu-west-2.outscale.com/outscale-official-packages/dhclient-configuration/dhclient-configuration-1.0.0-1-Centos7.x86_64.rpm
chroot /mnt rpm -i http://osu.eu-west-2.outscale.com/outscale-official-packages/fni/osc-fni-1.0.0-8.x86_64.rpm

#### CONFIGURATION
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /mnt/etc/selinux/config

#### CLEANUP
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys
umount /mnt
rm -rf /mnt/var/cache/yum
rm -rf /mnt/root/.ssh
rm -rf /mnt/root/.bash_history
rm -rf /mnt/home/centos/.ssh
rm -rf /mnt/home/centos/.bash_history
rm -rf /mnt/tmp/*
rm -rf /mnt/var/lib/dhcp/
rm -rf /mnt/var/tmp/*
rm -rf /mnt/var/log/*
rm -rf /mnt/var/lib/cloud/*

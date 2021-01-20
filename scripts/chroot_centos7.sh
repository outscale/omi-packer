#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-2009.qcow2
mv *.qcow2 centos7.qcow2
qemu-img convert ./centos7.qcow2 -O raw /dev/sda
rescan-scsi-bus.sh -a
partprobe
mount -o nouuid /dev/sda1 /mnt

#### CHROOT FIXES
cp /etc/resolv.conf /mnt/etc/resolv.conf
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

#### UPDATES
chroot /mnt/ yum upgrade -y
chroot /mnt/ yum clean all

#### OUTSCALE PACKAGES
chroot /mnt yum install -y https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20160516-1.x86_64.rpm
chroot /mnt yum install -y https://osu.eu-west-2.outscale.com/outscale-official-packages/dhclient-configuration/dhclient-configuration-1.0.0-1-Centos7.x86_64.rpm
yes | cp -i /tmp/cloud.cfg /mnt/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config_centos /mnt/etc/ssh/sshd_config
chroot /mnt yum list installed > /tmp/packages

#### CONFIGURATION
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /mnt/etc/selinux/config

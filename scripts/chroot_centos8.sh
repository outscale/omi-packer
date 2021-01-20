#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2
mv *.qcow2 centos8.qcow2
qemu-img convert ./centos8.qcow2 -O raw /dev/sda
rescan-scsi-bus.sh -a
partprobe
mount -o nouuid /dev/sda1 /mnt

#### CHROOT FIXES
cp /etc/resolv.conf /mnt/etc/resolv.conf
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

#### UPDATES
chroot /mnt/ dnf upgrade -y
chroot /mnt/ dnf clean all

#### OUTSCALE PACKAGES
chroot /mnt dnf install -y https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20160516-1.x86_64.rpm
cp /tmp/cloudinit/*.cfg /mnt/etc/cloud/cloud.cfg.d/
cp /tmp/sshd_config_centos /mnt/etc/ssh/sshd_config
chroot /mnt yum list installed > /tmp/packages

#### CONFIGURATION
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /mnt/etc/selinux/config

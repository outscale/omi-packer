#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img sg3_utils
cd /tmp
wget -q https://osu.eu-west-2.outscale.com/omi-packer-official/rhel-server-7.7-update-1-x86_64-kvm.qcow2
mv *.qcow2 rhel7.qcow2
qemu-img convert ./rhel7.qcow2 -O raw /dev/sda
rescan-scsi-bus.sh -a
mount -o nouuid /dev/sda1 /mnt

#### CHROOT FIXES
yes | cp -i /etc/resolv.conf /mnt/etc/resolv.conf
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys

#### OUTSCALE PACKAGES
chroot /mnt yum install -y https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20160516-1.x86_64.rpm
chroot /mnt yum install -y https://osu.eu-west-2.outscale.com/outscale-official-packages/dhclient-configuration/dhclient-configuration-1.0.0-1-Centos7.x86_64.rpm
yes | cp -i /tmp/cloud-rhel.cfg /mnt/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config_centos /mnt/etc/ssh/sshd_config
chroot /mnt yum list installed > /tmp/packages

#### CONFIGURATION
chroot /mnt systemctl disable NetworkManager
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /mnt/etc/selinux/config

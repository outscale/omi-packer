#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget
cd /tmp
wget -q http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.raw.tar.gz
wget -q https://cloud.centos.org/centos/7/images/sha256sum.txt
if [[ $(cat sha256sum.txt | grep -c `sha256sum CentOS-7-x86_64-GenericCloud.raw.tar.gz | cut -d\  -f1`) < 1 ]]; then exit 1; fi
tar -zxvf CentOS-7-x86_64-GenericCloud.raw.tar.gz
mv *.raw centos7.raw
dd if=./centos7.raw of=/dev/sda bs=1G status=progress conv=sparse
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

#### CLEANUP
rm -f /mnt/etc/resolv.conf
rm -rf /mnt/var/cache/yum
rm -rf /mnt/root/.ssh
rm -rf /mnt/root/.bash_history
rm -rf /mnt/tmp/*
rm -rf /mnt/var/lib/dhcp/
rm -rf /mnt/var/tmp/*
rm -rf /mnt/var/log/*
rm -rf /mnt/var/lib/cloud/*

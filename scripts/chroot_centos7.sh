#!/bin/bash

#### BASIC IMAGE
cd /tmp
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.raw.tar.gz
tar -zxvf CentOS-7-x86_64-GenericCloud.raw.tar.gz && mv *.raw centos7.raw
sudo dd if=/tmp/centos7.raw of=/dev/sda bs=1M status=progress
sudo xfs_admin -U generate /dev/sda1
sudo mount /dev/sda1 /mnt

#### CHROOT FIXES
sudo cp /etc/resolv.conf /mnt/etc/resolv.conf
sudo mount -o bind /dev /mnt/dev
sudo mount -o bind /proc /mnt/proc
sudo mount -o bind /sys /mnt/sys

#### UPDATES
sudo chroot /mnt/ yum upgrade -y
sudo chroot /mnt/ yum clean all

#### OUTSCALE PACKAGES

#### CLEANUP
sudo umount /mnt/dev
sudo umount /mnt/proc
sudo umount /mnt/sys
sudo umount /mnt
sudo rm -rf /mnt/var/cache/yum
sudo rm -rf /mnt/root/.ssh
sudo rm -rf /mnt/root/.bash_history
sudo rm -rf /mnt/home/centos/.ssh
sudo rm -rf /mnt/home/centos/.bash_history
sudo rm -rf /mnt/tmp/*
sudo rm -rf /mnt/var/lib/dhcp/
sudo rm -rf /mnt/var/tmp/*
sudo rm -rf /mnt/var/log/*
sudo rm -rf /mnt/var/lib/cloud/*

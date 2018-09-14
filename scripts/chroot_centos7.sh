#!/bin/bash

#### BASIC IMAGE
sudo yum install -y wget
cd /tmp
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.raw.tar.gz
tar -zxvf CentOS-7-x86_64-GenericCloud.raw.tar.gz && mv *.raw centos7.raw
sudo dd if=/tmp/centos7.raw of=/dev/sda bs=1M status=progress
sudo xfs_admin -U generate /dev/sda1
sudo mount /dev/sda1 /mnt

#### CHROOT FIXES
sudo cp /etc/resolv.conf /mnt/etc/resolv.conf
sudo mount -o bind /dev /mnt/dev

#### UPDATES
sudo chroot /mnt/ yum upgrade -y
sudo chroot /mnt/ yum clean all

#### OUTSCALE PACKAGES
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules-20160516-1.x86_64.rpm
sudo cp osc-udev-rules-20160516-1.x86_64.rpm /mnt/tmp/
sudo chroot /mnt/ rpm -i /tmp/osc-udev-rules-20160516-1.x86_64.rpm

#### CLEANUP
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

#### END STAGE
sudo umount /mnt

#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://repo.almalinux.org/almalinux/9.4/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2
qemu-img convert ./*.qcow2 -O raw /dev/sda

#### CUSTOM KERNEL WITH RECENT XFS SUPPORT
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
yum --disablerepo=\* --enablerepo=elrepo-kernel --enablerepo=elrepo-testing -y install kernel-ml
grub2-set-default 0
reboot
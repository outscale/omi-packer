#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://oos.eu-west-2.outscale.com/omi/qcow/rhel-baseos-9.0-x86_64-kvm.qcow2
qemu-img convert ./*.qcow2 -O raw /dev/sda

#### CUSTOM KERNEL WITH RECENT XFS SUPPORT
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm
yum --disablerepo=\* --enablerepo=elrepo-kernel --enablerepo=elrepo-testing -y install kernel-ml
grub2-set-default 0
reboot
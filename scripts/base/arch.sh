
#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt git
cd /tmp
wget -q https://mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg-20211201.40458.qcow2
mv *.qcow2 arch.qcow2
qemu-img convert ./arch.qcow2 -O raw /dev/sda

#### CUSTOM KERNEL WITH BTRFS SUPPORT
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
yum --disablerepo=\* --enablerepo=elrepo-kernel --enablerepo=elrepo-testing -y install kernel-ml btrfs-progs
grub2-set-default 0
reboot
#!/bin/bash
set -e

# REQUIREMENTS
yum install -y epel-release
yum install -y wget ntfs-3g ntfsprogs dosfstools
yum group install -y "Development Tools"

# MS-SYS (MICROSOFT MBR)
wget "https://sourceforge.net/projects/ms-sys/files/ms-sys%20stable/2.6.0/ms-sys-2.6.0.tar.gz/download"
tar xvzf ./download
cd ms-sys*/
make
make install

# PARTITION DISK
echo -e "n\np\n1\n\n\nt 1\n7\na\nw\n" | fdisk /dev/sda
mkfs.ntfs -f /dev/sda1
mkdir -p /mnt/hdd /mnt/iso

# DOWNLOAD AND WRITE ISO
cd /tmp
wget -q https://oos.eu-west-2.outscale.com/omi/iso/en_windows_10_enterprise_ltsc_2019_x64_dvd_5795bb03.iso
mv *.iso win.iso
mount -o loop /tmp/win.iso /mnt/iso
mount /dev/sda1 /mnt/hdd
cp -av /mnt/iso/* /mnt/hdd/
umount /mnt/iso

# MAKE ISO BOOTABLE
/usr/local/bin/ms-sys -n /dev/sda1
/usr/local/bin/ms-sys -7 /dev/sda
sync
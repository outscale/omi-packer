#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img
cd /tmp
wget -q http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
wget -q https://cloud-images.ubuntu.com/bionic/current/MD5SUMS
if [[ $(md5sum -c MD5SUMS 2>&1 | grep -c OK) < 1 ]]; then exit 1; fi
mv *.img bionic.img
qemu-img convert ./bionic.img -O raw bionic.raw
dd if=./bionic.raw of=/dev/sda bs=1G conv=sparse
mount /dev/sda1 /mnt

#### CHROOT FIXES
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys
mv /mnt/etc/resolv.conf{,.bak}
cp /etc/resolv.conf /mnt/etc/resolv.conf

#### UPDATES
chroot /mnt/ apt update -y
chroot /mnt/ apt upgrade -y

#### CONFIGURATION
echo 'GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"' >>/mnt/etc/default/grub
chroot /mnt/ update-grub

#### OUTSCALE PACKAGES
wget https://osu.eu-west-2.outscale.com/outscale-official-packages/udev/osc-udev-rules_20160516_amd64.deb -P /mnt/tmp
chroot /mnt/ dpkg -i /tmp/osc-udev-rules_20160516_amd64.deb
yes | cp -i /tmp/cloud.cfg /mnt/etc/cloud/cloud.cfg
yes | cp -i /tmp/sshd_config /mnt/etc/ssh/sshd_config

#### DOCKER
chroot /mnt/ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | chroot /mnt/ sudo apt-key add -
chroot /mnt/ apt install -y software-properties-common
chroot /mnt/ add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
chroot /mnt/ apt update -y
chroot /mnt/ apt install -y docker-ce
chroot /mnt/ systemctl enable docker-ce
chroot /mnt/ curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chroot /mnt/ chmod +x /usr/local/bin/docker-compose
chroot /mnt/ mkdir -p /opt/osc-docker-compose-runner/
yes | cp -i /tmp/docker-compose-runner.sh /mnt/opt/osc-docker-compose-runner/docker-compose-runner.sh
yes | cp -i /tmp/docker-compose-runner.service /mnt/etc/systemd/system/docker-compose-runner.service
chroot /mnt/ systemctl enable docker-compose-runner

chroot /mnt/ apt list --installed > /tmp/packages

dpkg-divert --local --divert /etc/cloud/cloud.cfg.default --rename /etc/cloud/cloud.cfg
dpkg-divert --local --divert /etc/ssh/sshd_config --rename /etc/ssh/sshd_config.default

#### CLEANUP
chroot /mnt/ apt clean
rm -f /mnt/etc/resolv.conf
mv /mnt/etc/resolv.conf.bak /mnt/etc/resolv.conf
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys
umount /mnt
rm -rf /mnt/var/cache/apt
rm -rf /mnt/root/.ssh
rm -rf /mnt/root/.bash_history
rm -rf /mnt/tmp/*
rm -rf /mnt/var/lib/dhcp/
rm -rf /mnt/var/tmp/*
rm -rf /mnt/var/log/*
rm -rf /mnt/var/lib/cloud/*

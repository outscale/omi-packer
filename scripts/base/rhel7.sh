#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://osu.eu-west-2.outscale.com/omi-packer-official/rhel-server-7.7-update-1-x86_64-kvm.qcow2
mv *.qcow2 rhel7.qcow2
qemu-img convert ./rhel7.qcow2 -O raw /dev/sda

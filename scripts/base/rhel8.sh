#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://oos.eu-west-2.outscale.com/omi/qcow/rhel-8.5-x86_64-kvm.qcow2
mv *.qcow2 rhel8.qcow2
qemu-img convert ./rhel8.qcow2 -O raw /dev/sda

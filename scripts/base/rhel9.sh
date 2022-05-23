#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://oos.eu-west-2.outscale.com/omi/qcow/rhel-baseos-9.0-x86_64-kvm.qcow2
qemu-img convert ./*.qcow2 -O raw /dev/sda

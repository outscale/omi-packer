#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q "$1"
mv *.qcow2 image.qcow2
qemu-img convert ./image.qcow2 -O raw /dev/sda

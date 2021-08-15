#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2
wget -q https://cdimage.debian.org/images/cloud/bullseye/latest/SHA512SUMS
if [[ $(cat SHA512SUMS | grep -c `sha512sum *.qcow2 | cut -d " " -f 1`) < 1 ]]; then exit 1; fi
mv *.qcow2 debian11.qcow2
qemu-img convert ./debian11.qcow2 -O raw /dev/sda

#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img sg3_utils libgcrypt
cd /tmp
wget -q http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
wget -q https://cloud-images.ubuntu.com/bionic/current/MD5SUMS
if [[ $(md5sum -c MD5SUMS 2>&1 | grep -c OK) < 1 ]]; then exit 1; fi
mv *.img bionic.img
qemu-img convert ./bionic.img -O raw /dev/sda

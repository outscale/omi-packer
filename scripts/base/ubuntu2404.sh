#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img sg3_utils libgcrypt
cd /tmp
wget -q https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img
wget -q https://cloud-images.ubuntu.com/releases/24.04/release/MD5SUMS
if [[ $(md5sum -c MD5SUMS 2>&1 | grep -c OK) < 1 ]]; then exit 1; fi
qemu-img convert ./*.img -O raw /dev/sda

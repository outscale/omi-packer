#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget
cd /tmp
wget -q https://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.raw
wget -q https://cdimage.debian.org/cdimage/openstack/current-10/MD5SUMS
if [[ $(cat MD5SUMS | grep -c `md5sum *.raw | cut -c -32`) < 1 ]]; then exit 1; fi
mv *.raw debian10.raw
dd if=./debian10.raw of=/dev/sda bs=1G status=progress conv=sparse

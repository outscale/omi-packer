#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://dl.rockylinux.org/pub/rocky/8.4/images/Rocky-8-GenericCloud-8.4-20210620.0.x86_64.qcow2
mv *.qcow2 centos8.qcow2
qemu-img convert ./centos8.qcow2 -O raw /dev/sda

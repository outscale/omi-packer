#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2
mv *.qcow2 centos8.qcow2
qemu-img convert ./centos8.qcow2 -O raw /dev/sda

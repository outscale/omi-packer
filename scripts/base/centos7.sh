
#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y wget qemu-img libgcrypt
cd /tmp
wget -q https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-2009.qcow2
mv *.qcow2 centos7.qcow2
qemu-img convert ./centos7.qcow2 -O raw /dev/sda

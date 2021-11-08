#!/bin/bash
set -e

#### BASIC IMAGE
yum install -y epel-release
yum install -y wget qemu-img libgcrypt p7zip p7zip-plugins
cd /tmp
wget -q "$1"

# Extract image if gunzipped
if [ -f *.gz ]; then 
    7z x *.gz
fi

# Fix unclear file extensions
if [ -f *.img ]; then 
    if [[ `file *.img` =~ "QCOW" ]]; then 
        mv *.img image.qcow2
    else
        exit 1
    fi
fi

# Copy image to disk
if [ -f *.qcow2 ]; then 
    qemu-img info *.qcow2
    qemu-img convert *.qcow2 -O raw /dev/sda
fi
if [ -f *.raw ]; then 
    dd if=*.raw of=/dev/sda bs=1G status=progress conv=sparse
fi

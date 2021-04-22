#!/bin/bash
set -e

if [[ ! "$1" == "debian"* ]] && [[ ! "$1" == "ubuntu"* ]]; then
    yum install -y augeas
    augtool -r /mnt -s set /files/etc/selinux/config/SELINUX disabled
fi

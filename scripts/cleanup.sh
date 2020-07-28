#!/bin/bash

rm -f /mnt/etc/resolv.conf
rm -rf /mnt/var/cache/yum
rm -rf /mnt/root/.ssh
rm -rf /mnt/root/.bash_history
rm -rf /mnt/tmp/*
rm -rf /mnt/var/lib/dhcp/
rm -rf /mnt/var/tmp/*
find /mnt/var/log ! -type d -exec rm '{}' \;
rm -rf /mnt/var/lib/cloud/*

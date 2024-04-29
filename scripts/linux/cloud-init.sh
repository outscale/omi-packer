#!/bin/bash
set -e

cp /tmp/cloudinit/*.cfg /mnt/etc/cloud/cloud.cfg.d/

if [[ "$1" == "ubuntu2204" ]] || [[ "$1" == "ubuntu2404" ]] || [[ "$1" == "rocky9" ]]; then
	#Add FNI Hotplug support
	cp /tmp/cloudinit-specific/06_hotplug.cfg /mnt/etc/cloud/cloud.cfg.d/
fi

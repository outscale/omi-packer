#/bin/bash
set -e

if [[ "$1" == "rhel"*"csp" ]]; then
    echo "169.254.169.254 rhsatellite.outscale.internal" >> /mnt/etc/hosts
    curl -k --output /mnt/tmp/katello-ca-consumer-latest.noarch.rpm https://169.254.169.254:4888/pub/katello-ca-consumer-latest.noarch.rpm
    chroot /mnt yum localinstall -y /tmp/katello-ca-consumer-latest.noarch.rpm

    if [[ "$1" == "rhel8csp" ]]; then
      cp /tmp/cloudinit-specific/05_rhel8.cfg /mnt/etc/cloud/cloud.cfg.d/
    elif [[ "$1" == "rhel7csp" ]]; then
      cp /tmp/cloudinit-specific/05_rhel7.cfg /mnt/etc/cloud/cloud.cfg.d/
    fi
fi

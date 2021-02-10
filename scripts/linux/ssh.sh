#!/bin/bash
set -e

yum install -y augeas

augtool -r /mnt -s <<EOF
set /files/etc/ssh/sshd_config/X11Forwarding no
set /files/etc/ssh/sshd_config/PermitTunnel no
set /files/etc/ssh/sshd_config/PermitRootLogin no
set /files/etc/ssh/sshd_config/RSAAuthentication yes
set /files/etc/ssh/sshd_config/PubkeyAuthentication yes
set /files/etc/ssh/sshd_config/PasswordAuthentication no
set /files/etc/ssh/sshd_config/UseDNS no
set /files/etc/ssh/sshd_config/ChallengeResponseAuthentication no
set /files/etc/ssh/sshd_config/GSSAPIAuthentication no
EOF

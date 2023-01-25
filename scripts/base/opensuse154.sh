#!/bin/bash
set -eo pipefail

#### BASIC IMAGE
IMAGE_FILE="openSUSE-Leap-15.4.x86_64-1.0.1-EC2-Build2.200.raw.xz"
IMAGE_URL="https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.4/images/${IMAGE_FILE}"
IMAGE_SHA_URL="https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.4/images/${IMAGE_FILE}.sha256"

# curl, sha256sum and xz already installed in basic centos 7+ images
cd /tmp
curl --location --silent --output "${IMAGE_FILE}" "$IMAGE_URL"
curl --location --silent "$IMAGE_SHA_URL" | sha256sum -c
xzcat "${IMAGE_FILE}" | dd of=/dev/sda
sync

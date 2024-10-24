#!/bin/sh
if [ "$2" = "up" ]; then
    if [ -n "$DHCP4_NTP_SERVERS" ]; then
        chronyc delete sources
        for server in $DHCP4_NTP_SERVERS; do
            chronyc add server $server iburst
        done
        systemctl restart chronyd
    fi
fi
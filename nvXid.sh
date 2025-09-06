#!/usr/bin/env bash

# Extract the last 10 Xid-related messages from syslog
errors=$(grep -a "Xid" /var/log/syslog | tail -n 10)

# If errors are found, send them as a single alert message
if [[ -n "$errors" ]]; then
    echo "$errors" | message danger "GPU Xid errors detected" payload
fi

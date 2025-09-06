#!/usr/bin/env bash

# nvXid.sh — track new NVIDIA Xid errors in syslog

SYSLOG="/var/log/syslog"
STATE_FILE="/var/tmp/nvXid.pos"

# Get the current size of the syslog file
CUR_SIZE=$(stat -c%s "$SYSLOG")

# If the state file doesn't exist yet, create it and exit (avoid sending old errors)
if [[ ! -f "$STATE_FILE" ]]; then
    echo "$CUR_SIZE" > "$STATE_FILE"
    exit 0
fi

# Read the previous size
LAST_SIZE=$(cat "$STATE_FILE")

# If syslog has been rotated/truncated, start from the beginning
if [[ "$CUR_SIZE" -lt "$LAST_SIZE" ]]; then
    LAST_SIZE=0
fi

# Extract new lines since last check and filter for Xid errors
errors=$(tail -c +$((LAST_SIZE+1)) "$SYSLOG" | grep -a "Xid")

# Update the position for the next run
echo "$CUR_SIZE" > "$STATE_FILE"

# If there are errors, send them as a single danger message to HiveOS
if [[ -n "$errors" ]]; then
    echo "$errors" | message danger "New GPU Xid errors detected" payload
fi

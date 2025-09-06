#!/usr/bin/env bash

# nvErrorCheck.sh — track NVIDIA Xid errors in syslog, send last 10 lines on first run

SYSLOG="/var/log/syslog"
STATE_FILE="/var/tmp/nvErrorCheck.pos"

# Get current size of syslog
CUR_SIZE=$(stat -c%s "$SYSLOG")

# If state file exists, read last position; else set flag for first run
if [[ -f "$STATE_FILE" ]]; then
    LAST_SIZE=$(cat "$STATE_FILE")
    FIRST_RUN=0
    [[ "$CUR_SIZE" -lt "$LAST_SIZE" ]] && LAST_SIZE=0
else
    LAST_SIZE=0
    FIRST_RUN=1
fi

# On first run: take only last 10 Xid lines
if [[ $FIRST_RUN -eq 1 ]]; then
    errors=$(tail -n 10 "$SYSLOG" | grep -a "Xid")
else
    # Subsequent runs: take new lines since last check
    errors=$(tail -c +$((LAST_SIZE+1)) "$SYSLOG" | grep -a "Xid")
fi

# Send errors if any
if [[ -n "$errors" ]]; then
    echo "$errors" | message danger "GPU Xid errors detected" payload
fi

# Update position for next run
echo "$CUR_SIZE" > "$STATE_FILE"

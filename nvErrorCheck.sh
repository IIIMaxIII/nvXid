#!/usr/bin/env bash
# nvErr — track NVIDIA Xid errors in syslog
# modes: start (default), rch, recheck (ignore state, show last 10 Xid errors)

SYSLOG="/var/log/syslog"
STATE_FILE="/var/tmp/nvErr.pos"
MODE="${1:-start}"  # default is 'start'

check_errors() {
    local first_run=$1
    local last_size=$2
    local errors

    if [[ $first_run -eq 1 ]]; then
        errors=$(tail -n 10 "$SYSLOG" | grep -a "Xid")
    else
        errors=$(tail -c +$((last_size+1)) "$SYSLOG" | grep -a "Xid")
    fi

    if [[ -n "$errors" ]]; then
        echo "$errors" | message danger "GPU Xid errors detected" payload
    fi
}

if [[ "$MODE" == "rch" || "$MODE" == "recheck" ]]; then
    # Ignore state file, show last 10 Xid errors
    check_errors 1
    exit 0
fi

# standard 'start' mode
CUR_SIZE=$(stat -c%s "$SYSLOG")
if [[ -f "$STATE_FILE" ]]; then
    LAST_SIZE=$(cat "$STATE_FILE")
    FIRST_RUN=0
    [[ "$CUR_SIZE" -lt "$LAST_SIZE" ]] && LAST_SIZE=0
else
    LAST_SIZE=0
    FIRST_RUN=1
fi

check_errors $FIRST_RUN "$LAST_SIZE"

# update state
echo "$CUR_SIZE" > "$STATE_FILE"

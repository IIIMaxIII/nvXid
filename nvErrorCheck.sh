#!/usr/bin/env bash
# nvErr.sh — trace Xid errors in syslog and notify via /hive/bin/message

set -euo pipefail

SYSLOG="/var/log/syslog"
STATE_FILE="/var/tmp/nvErr.pos"
MODE="${1:-start}"  # default is 'start'

# Config
CONFIG_FILE="/hive/bin/nvErr.cfg"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"  # expects TELEGRAM_TOKEN, CHAT_ID
    TELEGRAM_ENABLED=1
else
    echo "Config file $CONFIG_FILE not found — Telegram disabled."
    TELEGRAM_ENABLED=0
fi

send_telegram() {
    [[ $TELEGRAM_ENABLED -eq 0 ]] && return  # skip if no config
    local msg="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d parse_mode="Markdown" \
        -d disable_web_page_preview=true \
        -d text="$msg" >/dev/null
}

notify() {
    local msg="$1"
    send_telegram "$msg"
    # call external message script (Hive)
    /hive/bin/message danger "GPU Xid errors detected" payload
}

check_errors() {
    local first_run=$1
    local last_size=$2
    local errors

    if [[ $first_run -eq 1 ]]; then
        errors=$(tail -n 100 "$SYSLOG" | grep -ai "Xid")
    else
        errors=$(tail -c +$((last_size+1)) "$SYSLOG" | grep -ai "Xid")
    fi

    if [[ -n "$errors" ]]; then
        local msg=$'⚠️ *GPU Xid errors detected:*\n```\n'"$errors"$'\n```'
        notify "$msg"
    fi
}

# Main
if [[ "$MODE" == "rc" || "$MODE" == "recheck" ]]; then
    check_errors 1 0
    exit 0
fi

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

# Save current position
echo "$CUR_SIZE" > "$STATE_FILE"

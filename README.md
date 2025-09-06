# nvErr

`nvErr` is a Bash script for monitoring GPU Xid errors in the system log (`/var/log/syslog`) and sending notifications via Telegram and HiveOS. It is designed for mining rigs or systems with NVIDIA GPUs.

---

## Features

* Detects NVIDIA GPU Xid errors in `syslog`.
* Sends alerts to **Telegram** with Markdown formatting.
* Sends alerts to **HiveOS** (optionally only during local execution).
* Prints errors to console for local monitoring or external shell use.
* Supports incremental checking:

  * On first run, checks the last `INITIAL_LINES` lines.
  * On subsequent runs, checks **only new log lines**.
* Handles log rotation automatically.
* Optional command-line argument to check a specific number of last lines, ignoring previous state.

---

## Requirements

* Bash `4.x+`
* `curl` (for Telegram notifications)
* HiveOS agent `/hive/bin/message` (optional)
* NVIDIA drivers generating Xid messages in syslog

---

## Configuration

The script uses an existing configuration file at `/hive/bin/nvErr.cfg` with the following variables:

```bash
TELEGRAM_TOKEN="your_bot_token_here"
CHAT_ID="your_chat_id_here"
```

* If the file or variables are missing or empty, Telegram notifications are **disabled**, but console and HiveOS messages will still work.

---

## Usage

### Run normally (incremental)

```bash
./nvErr.sh
```

* Checks only new log lines since the last run.
* First run checks `INITIAL_LINES` last lines (default `100`, configurable inside the script).

### Run with a specific number of lines (ignore previous state)

```bash
./nvErr.sh 50
```

* Checks the last 50 lines of the syslog regardless of previous runs.

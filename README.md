**Description:**
The `nvErr.sh` script monitors GPU-related Xid errors in the Linux system log (`/var/log/syslog`). When such errors are detected, it notifies the user via Telegram (if configured) and through a local notification script `/hive/bin/message`.

---

## Features

1. **GPU Xid Error Monitoring**
   The script scans the system log for messages containing `Xid` (case-insensitive).

2. **Notifications**

   * **Telegram:** via bot if configuration file `/hive/bin/nvErr.cfg` exists with `TELEGRAM_TOKEN` and `CHAT_ID`.
   * **Local notifications:** via `/hive/bin/message`.

3. **Position Tracking**
   The script saves the last read position in `/var/tmp/nvErr.pos` to process only new log entries on subsequent runs.

4. **Run Modes**

   * `start` (default): checks for new errors since the last run.
   * `rc` or `recheck`: checks the last 100 lines of the log regardless of previous state.

---

## Usage

```bash
./nvErr.sh [MODE]
```

**Parameters:**

| Parameter        | Description                                        |
| ---------------- | -------------------------------------------------- |
| `start`          | Checks for new errors since the last run (default) |
| `rc` / `recheck` | Checks the last 100 lines of the log               |

---

## Telegram Configuration

Create the file `/hive/bin/nvErr.cfg` with the following content:

```bash
TELEGRAM_TOKEN="your_bot_token"
CHAT_ID="your_chat_id"
```

If the file is missing, Telegram notifications are disabled.

---

## How It Works

1. Determines the size of the system log `/var/log/syslog`.
2. Reads the state file `/var/tmp/nvErr.pos` to know where to continue from.
3. If it’s the first run or the log has shrunk (e.g., after rotation), it checks the log from the beginning.
4. Filters lines containing the keyword `Xid`.
5. If errors are found:

   * Builds a formatted message with the errors.
   * Sends it to Telegram (if configured).
   * Sends it via `/hive/bin/message`.
6. Saves the current log position to `/var/tmp/nvErr.pos`.

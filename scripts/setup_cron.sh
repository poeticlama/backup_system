#!/bin/bash

CONFIG_FILE="$(dirname "$0")/../config/backup.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

source "$CONFIG_FILE"

CRON_SCHEDULE="${CRON_TIME:-0 3 * * *}"
MONITOR_DELAY_MINUTES=5

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$(realpath "$SCRIPTS_DIR/../logs")"
mkdir -p "$LOG_DIR"

CRON_JOB_BACKUP="$CRON_SCHEDULE cd $SCRIPTS_DIR && ./backup.sh >> $LOG_DIR/cron_backup.log 2>&1"
CRON_JOB_MONITOR="$(echo "$CRON_SCHEDULE" | awk -v delay="$MONITOR_DELAY_MINUTES" '{printf "%d %s %s %s %s", ($1 + delay) % 60, $2, $3, $4, $5}') cd $SCRIPTS_DIR && ./monitor_backups.sh >> $LOG_DIR/monitor.log 2>&1"

(
  crontab -l 2>/dev/null | grep -v 'backup.sh\|monitor_backups.sh'
  echo "$CRON_JOB_BACKUP"
  echo "$CRON_JOB_MONITOR"
) | crontab -

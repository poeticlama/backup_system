#!/bin/bash
# This script shoud check backups and somehow alert about errors
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$SCRIPT_DIR/.."
CONFIG_FILE="$PROJECT_ROOT/config/backup.conf"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/monitor_$(date +%Y-%m-%d_%H-%M-%S).log"

mkdir -p "$LOG_DIR"

echo "Monitoring backups..." | tee -a "$LOG_FILE"
echo "$(date)" | tee -a "$LOG_FILE"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config not found: $CONFIG_FILE" | tee -a "$LOG_FILE"
  exit 1
fi

source "$CONFIG_FILE"

BACKUP_ROOT="${BACKUP_DIR:-$PROJECT_ROOT/backups}"

if [[ ! -d "$BACKUP_ROOT" ]]; then
  echo "Backup directory not found: $BACKUP_ROOT" | tee -a "$LOG_FILE"
  exit 1
fi

LATEST_BACKUP=$(ls -1 "$BACKUP_ROOT" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$' | sort | tail -n 1)

if [[ -z "$LATEST_BACKUP" ]]; then
  echo "No backups found in $BACKUP_ROOT" | tee -a "$LOG_FILE"
  exit 0
fi

echo "Latest backup found: $LATEST_BACKUP" | tee -a "$LOG_FILE"

TARGET_DIR="$BACKUP_ROOT/$LATEST_BACKUP"

for SRC in "${SOURCE_DIRS[@]}"; do
  NAME=$(basename "$SRC")
  FILE="$TARGET_DIR/${NAME}_${LATEST_BACKUP}.tar.gz"
  if [[ -f "$FILE" ]]; then
    echo "Archive found for $NAME" | tee -a "$LOG_FILE"
  else
    echo "Missing archive for $NAME" | tee -a "$LOG_FILE"
  fi
done

if [[ -n "$DB_LIST" ]]; then
  DB_PATH="$TARGET_DIR/databases"
  if [[ ! -d "$DB_PATH" ]]; then
    echo "Database folder missing: $DB_PATH" | tee -a "$LOG_FILE"
  else
    for DB in "${DB_LIST[@]}"; do
      FILE="$DB_PATH/${DB}_${LATEST_BACKUP}.sql"
      if [[ -f "$FILE" ]]; then
        echo "Dump found for DB $DB" | tee -a "$LOG_FILE"
      else
        echo "Missing dump for DB $DB" | tee -a "$LOG_FILE"
      fi
    done
  fi
fi

echo "Monitoring complete" | tee -a "$LOG_FILE"

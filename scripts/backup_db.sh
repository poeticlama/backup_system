#!/bin/bash

TARGET_DIR="$1"
DATE="$2"
SCRIPT_DIR="$(dirname "$0")"
CONFIG_FILE="$SCRIPT_DIR/../config/backup.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Config file not found: $CONFIG_FILE"
  exit 1
fi

source "$CONFIG_FILE"

DB_BACKUP_DIR="$TARGET_DIR/databases"
mkdir -p "$DB_BACKUP_DIR"

if [[ -z "$DB_LIST" ]]; then
  echo "No databases specified in config"
  exit 0
fi

for DB in "${DB_LIST[@]}"; do
  OUTPUT_FILE="$DB_BACKUP_DIR/${DB}_${DATE}.sql"
  echo "Backing up DB: $DB -> $OUTPUT_FILE"
  pg_dump -U "$DB_USER" "$DB" > "$OUTPUT_FILE"
  if [[ $? -ne 0 ]]; then
    echo "Failed to backup database: $DB"
  else
    echo "Backup successful: $DB"
  fi
done
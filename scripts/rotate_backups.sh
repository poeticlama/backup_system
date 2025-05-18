#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONFIG="$PROJECT_ROOT/config/backup.conf"

if [[ ! -f "$CONFIG" ]]; then
  echo "Config not found: $CONFIG"
  exit 1
fi

source "$CONFIG"

BACKUP_ROOT="$PROJECT_ROOT/backups"

# Check if BACKUPS_NUM is set, default to 2 if not
BACKUPS_NUM=${BACKUPS_NUM:-2}

echo "Rotating backups, keeping $BACKUPS_NUM most recent backups"

# Get list of backups sorted by modification time (newest first)
BACKUPS=($(ls -td "$BACKUP_ROOT"/*/ 2>/dev/null))

# Calculate how many backups to delete
DELETE_COUNT=$((${#BACKUPS[@]} - BACKUPS_NUM))

if [[ $DELETE_COUNT -gt 0 ]]; then
  echo "Found ${#BACKUPS[@]} backups, deleting $DELETE_COUNT oldest"

  # Loop through backups we need to delete (from oldest)
  for ((i = ${#BACKUPS[@]} - 1; i >= BACKUPS_NUM; i--)); do
    BACKUP_TO_DELETE="${BACKUPS[$i]}"
    echo "Deleting old backup: $BACKUP_TO_DELETE"
    rm -rf "$BACKUP_TO_DELETE"
  done
else
  echo "Found ${#BACKUPS[@]} backups, no need to delete (keeping $BACKUPS_NUM)"
fi

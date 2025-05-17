#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PROJECT_ROOT="$SCRIPT_DIR/.."
CONFIG_FILE="$PROJECT_ROOT/config/backup.conf"

# Load config
source "$CONFIG_FILE"

BACKUP_ROOT="${BACKUP_DIR:-$PROJECT_ROOT/backups}"
BACKUPS_NUM="${BACKUPS_NUM:-10}" # Fallback to 10 if not set

# Validate BACKUPS_NUM is a number
if ! [[ "$BACKUPS_NUM" =~ ^[0-9]+$ ]]; then
    echo "ERROR: BACKUPS_NUM must be a number. Current value: $BACKUPS_NUM"
    exit 1
fi

# Get sorted list of backup directories by name (newest first)
cd "$BACKUP_ROOT" || exit 1
backup_dirs=($(ls -d 20*_* 2>/dev/null | sort -r))
cd - >/dev/null

num_dirs=${#backup_dirs[@]}
echo "Found $num_dirs backups. Max allowed: $BACKUPS_NUM"

# Remove oldest backups if exceeding limit
if [[ $num_dirs -gt $BACKUPS_NUM ]]; then
    dirs_to_remove=("${backup_dirs[@]:$BACKUPS_NUM}")
    for dir in "${dirs_to_remove[@]}"; do
        full_path="$BACKUP_ROOT/$dir"
        echo "Removing old backup: $full_path"
        rm -rf "$full_path"
    done
    echo "Removed $((num_dirs - BACKUPS_NUM)) old backups"
else
    echo "No backups to remove"
fi
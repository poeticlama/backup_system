#!/bin/bash
# This script shout rotate backups (delete old backups)

set -euo pipefail

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PROJECT_ROOT="$SCRIPT_DIR/.."
CONFIG_FILE="$PROJECT_ROOT/config/backup.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

BACKUP_ROOT="${BACKUP_DIR:-$PROJECT_ROOT/backups}"

if [[ ! -d "$BACKUP_ROOT" ]]; then
    echo "Backup directory not found: $BACKUP_ROOT"
    exit 1
fi

# Get backup directories sorted by name (newest first)
backup_dirs=($(find "$BACKUP_ROOT" -maxdepth 1 -type d -name '20*_*' | sort -r))
num_to_keep=$BACKUPS_NUM
num_dirs=${#backup_dirs[@]}

if [[ $num_dirs -gt $num_to_keep ]]; then
    dirs_to_remove=("${backup_dirs[@]:$num_to_keep}")
    for dir in "${dirs_to_remove[@]}"; do
        echo "Removing old backup: $dir"
        rm -rf "$dir"
    done
    echo "Removed $((num_dirs - num_to_keep)) old backups."
else
    echo "No backups to remove. Current: $num_dirs, Max allowed: $num_to_keep"
fi
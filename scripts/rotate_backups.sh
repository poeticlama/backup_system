#!/bin/bash
# This script shout rotate backups (delete old backups)

set -euo pipefail

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PROJECT_ROOT="$SCRIPT_DIR/.."
CONFIG_FILE="$PROJECT_ROOT/config/backup.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

source "$CONFIG_FILE"

: "BACKUPS_NUM=${BACKUPS_NUM}"
: "BACKUP_DIR=${BACKUP_DIR:-}"

BACKUP_ROOT="${BACKUP_DIR:-$PROJECT_ROOT/backups}"

if [[ ! -d "$BACKUP_ROOT" ]]; then
    echo "Backup directory not found: $BACKUP_ROOT" >&2
    exit 1
fi

backup_dirs=()
while IFS= read -r -d $'\0' dir; do
    dir_name=$(basename "$dir")
    if [[ $dir_name =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
        timestamp=$(date -d "${dir_name//_/ }" +%s 2>/dev/null)
        if [[ -n $timestamp ]]; then
            backup_dirs+=("$timestamp:$dir")
        fi
    fi
done < <(find "$BACKUP_ROOT" -maxdepth 1 -type d -print0)

IFS=$'\n' sorted_dirs=($(sort -rn <<< "${backup_dirs[*]}"))
unset IFS

num_to_keep=$(( BACKUPS_NUM > 0 ? BACKUPS_NUM : 1 ))
num_dirs=${#sorted_dirs[@]}

if [[ $num_dirs -gt $num_to_keep ]]; then
    echo "Found $num_dirs backups (max allowed: $num_to_keep)"
    for entry in "${sorted_dirs[@]:$num_to_keep}"; do
        dir_path="${entry#*:}"
        echo "Removing old backup: $dir_path"
        rm -rf "$dir_path"
    done
    echo "Removed $((num_dirs - num_to_keep)) old backups"
else
    echo "No backups to remove. Current: $num_dirs, Max allowed: $num_to_keep"
fi
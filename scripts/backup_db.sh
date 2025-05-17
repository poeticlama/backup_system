#!/bin/bash
# Some code for backup databases (using pg_dump)

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <target_dir> <date>"
    exit 1
fi

TARGET_DIR="$1"
DATE="$2"

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PROJECT_ROOT="$SCRIPT_DIR/.."
CONFIG_FILE="$PROJECT_ROOT/config/backup.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

DB_BACKUP_DIR="$TARGET_DIR/databases"
mkdir -p "$DB_BACKUP_DIR"

exit_code=0

for DB in "${DB_LIST[@]}"; do
    OUTPUT_FILE="$DB_BACKUP_DIR/${DB}_${DATE}.sql"
    echo "Backing up database '$DB'..."
    if pg_dump -U "$DB_USER" -Fc "$DB" > "$OUTPUT_FILE"; then
        echo "Success: $DB dumped to $OUTPUT_FILE"
    else
        echo "ERROR: Failed to backup $DB"
        exit_code=1
    fi
done

exit $exit_code
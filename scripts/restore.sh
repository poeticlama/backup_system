#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Usage: $0 /path/to/backup_dir"
  exit 1
fi

BACKUP_DIR="$1"

if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "Backup directory does not exist: $BACKUP_DIR"
  exit 1
fi

echo "Restoring from backup: $BACKUP_DIR"

for ARCHIVE in "$BACKUP_DIR"/*.tar.gz; do
  [[ -e "$ARCHIVE" ]] || continue
  NAME=$(basename "$ARCHIVE" | cut -d_ -f1)
  echo "Restoring directory: $NAME from $ARCHIVE"
  tar -xzf "$ARCHIVE" -C /
done

DB_BACKUP_DIR="$BACKUP_DIR/databases"
if [[ -d "$DB_BACKUP_DIR" ]]; then
  for SQL_FILE in "$DB_BACKUP_DIR"/*.sql; do
    [[ -e "$SQL_FILE" ]] || continue
    DB_NAME=$(basename "$SQL_FILE" | sed -E 's/_.*\.sql$//')
    echo "Restoring database: $DB_NAME from $SQL_FILE"
    psql -U postgres "$DB_NAME" < "$SQL_FILE"
  done
else
  echo "No database backups found in $DB_BACKUP_DIR"
fi

echo "Restore complete."

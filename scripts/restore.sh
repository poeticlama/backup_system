#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <backup_path>"
  echo "Available backups:"
  ls -td "$(dirname "$0")/../backups"/*/ 2>/dev/null | awk -F/ '{print $(NF-1)}'
  exit 1
fi

BACKUP_PATH="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$PROJECT_ROOT/config/backup.conf"

if [[ ! -d "$BACKUP_PATH" ]]; then
  echo "Backup directory not found: $BACKUP_PATH"
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "Config not found: $CONFIG"
  exit 1
fi
source "$CONFIG"

echo "Restoring from backup: $BACKUP_PATH"

for SRC in "${SOURCE_DIRS[@]}"; do
  NAME=$(basename "$SRC" | cut -d. -f1)
  TAR_FILE=$(find "$BACKUP_PATH" -name "${NAME}_*.tar.gz" | head -n 1)

  if [[ -f "$TAR_FILE" ]]; then
    echo "Restoring files for $NAME from $TAR_FILE to $SRC"
    mkdir -p "$SRC"
    tar -xzf "$TAR_FILE" -C "$(dirname "$SRC")" --strip-components=1
    echo "Files restored successfully for $NAME"
  else
    echo "No backup file found for $NAME"
  fi
done

DB_BACKUP_DIR="$BACKUP_PATH/databases"
if [[ -d "$DB_BACKUP_DIR" && ! -z "$DB_LIST" ]]; then
  echo "Restoring databases..."

  for DB in "${DB_LIST[@]}"; do
    DB_FILE=$(find "$DB_BACKUP_DIR" -name "${DB}_*.sql" | head -n 1)

    if [[ -f "$DB_FILE" ]]; then
      echo "Restoring database $DB from $DB_FILE"
      # Используем sudo -u postgres для peer-аутентификации
      sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB;"
      sudo -u postgres psql -c "CREATE DATABASE $DB;"
      sudo -u postgres psql "$DB" <"$DB_FILE"
      echo "Database $DB restored successfully"
    else
      echo "No backup file found for database $DB"
    fi
  done
else
  echo "No databases to restore or backup directory not found"
fi

echo "Restore completed from $BACKUP_PATH"

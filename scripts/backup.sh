#!/bin/bash

# To be fixed later 

CONFIG="../../config/backup.conf"

if [[ ! -f "$CONFIG" ]]; then
  echo "Config not found: $CONFIG"
  exit 1
fi

source "$CONFIG"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_ROOT="../../backups}"
TARGET_DIR="$BACKUP_ROOT/$DATE"

mkdir -p "$TARGET_DIR"

echo "Starting backup: $DATE into Backup directory: $TARGET_DIR"

for SRC in "${SOURCE_DIRS[@]}"; do
	NAME=$(basename"$SRC")
	TAR_FILE="{$TARGET_DIR}/${NAME}_${DATE}
	tar -czf "$TAR_FILE" "$SRC"
	# Here are some logs about success (or failure) of archives
done

if [[ ! -z "$DB_LIST" ]]; then
	../backup_db.sh "$TARGET_DIR" "$DATE"
else
	echo "No DB listed"
fi


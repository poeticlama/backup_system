#!/bin/bash

# To be fixed later 

SOURCE_DIR="~"  # Just backup home directory
BACKUP_DIR="backups" # Path to save backup

DATE=$(date +%Y-%m-%d_%H-%M-%S)

mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/backup_$DATE.tar.gz" "$SOURCE_DIR"

if [ $? -eq 0 ]; then
  echo "Backup created successfully: $BACKUP_DIR/backup_$DATE.tar.gz"
else
  echo "Some error occurred"
fi

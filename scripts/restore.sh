#!/bin/bash
# This script should restore data via saved backups
BACKUP_DIR="/backups"
RESTORE_LOG="/var/log/restore.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

check_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "[$TIMESTAMP] ERROR: Backup directory $BACKUP_DIR not found." | tee -a "$RESTORE_LOG"
        exit 1
    fi
}

list_backups() {
    echo "Available backups:"
    ls -lh "$BACKUP_DIR" | grep -E '*.tar.gz|*.sql.gz' | nl
}
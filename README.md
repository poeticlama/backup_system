# Automated Backup and Disaster Recovery System

A robust solution for automated file and database backups, storage management, and disaster recovery.  
Developed using Bash scripting, Cron scheduling, and PostgreSQL tools.  

---

## Table of Contents
- [Project Overview](#project-overview)
- [Installation & Dependencies](#installation--dependencies)
- [Configuration](#configuration)
  - [Config File (`backup.conf`)](#config-file-backupconf)
  - [Cron Setup](#cron-setup)
- [Usage](#usage)
- [Testing](#testing)
- [Resources](#resources)

---

## Project Overview

### Key Features:
- **Automated Backups**: Scripts to back up files (tar) and PostgreSQL databases (`pg_dump`).  
- **Retention Policies**: Rotate backups to retain only the latest `BACKUPS_NUM` copies.  
- **Restoration**: Restore files/databases from backups with `restore.sh`.  
- **Monitoring**: Log backup status and alert on failures via `monitor_backups.sh`.  
- **Cron Integration**: Schedule backups and monitoring tasks automatically.  

###  Demo Video:
- [Google Drive Link](https://drive.google.com/file/d/1fS92tTjByjwr1tauqKwmwaoK3VQPVXAM/view)  

---

## Installation & Dependencies

### Requirements:
- **Bash** (v4.0+)  
- **PostgreSQL** (for database backups)  
- **Cron** (e.g., `cron` or `systemd-timers`)  

### Steps:
1. Clone the repository:  
   ```bash
   git clone https://github.com/poeticlama/backup_system.git
   cd backup_system
   ```
2. Ensure scripts are executable:  
   ```bash
   chmod +x scripts/*.sh
   ```

---

## Configuration

### Config File
Located in `config/backup.conf`. Configure the following variables:  
```bash
SOURCE_DIRS=( "/home/${USER}/backup_system/test_project/" )  # Directories to back up
DB_LIST=( "test_db" )                                        # PostgreSQL databases to back up
BACKUPS_NUM=3                                                # Number of backups to retain
BACKUP_TIME="3:00"                                           # Scheduled time (HH:MM format)
```

- **`SOURCE_DIRS`**: Add paths to directories you want to back up.  
- **`DB_LIST`**: List PostgreSQL database names. Ensure the user running the script has `pg_dump` permissions.  
- **`BACKUPS_NUM`**: Older backups beyond this count will be deleted.  
- **`BACKUP_TIME`**: Cron schedule (default: `0 3 * * *` for 3:00 AM).  

### Cron Setup
The `scripts/setup_cron.sh` script configures Cron jobs automatically:  
1. **Run the setup script**:  
   ```bash
   ./scripts/setup_cron.sh
   ```
2. **What it does**:  
   - Reads `BACKUP_TIME` from `backup.conf` to schedule backups (e.g., `3:00` → `0 3 * * *`).  
   - Adds a delayed monitoring job (`monitor_backups.sh`) 5 minutes after the backup.  
   - Logs output to `logs/cron_backup.log` and `logs/monitor.log`.  

**Manual Cron Editing**:  
To modify schedules, update `BACKUP_TIME` and rerun `setup_cron.sh`, or edit crontab directly:  
```bash
crontab -e
```

---

## Usage

### Scripts:
- **`backup.sh`**: Creates timestamped backups of files and databases.  
- **`rotate_backups.sh`**: Deletes backups older than `BACKUPS_NUM`.  
- **`restore.sh`**: Restores files/databases from a specified backup.  
- **`monitor_backups.sh`**: Checks backup integrity and logs issues.  

### Manual Execution:
```bash
# Run backup
./scripts/backup.sh

# Rotate backups (retain only BACKUPS_NUM)
./scripts/rotate_backups.sh

# Restore from backup (replace TIMESTAMP)
./scripts/restore.sh /path/to/backup_20231001_0300

# Monitor backups
./scripts/monitor_backups.sh
```

---

## Testing

### Backup Test:
1. Simulate file/database creation.  
2. Run `backup.sh`.  
3. Verify archives in `backups/` and SQL dumps in `backups/db/`.  

### Rotation Test:
1. Create more than `BACKUPS_NUM` backups using `backup.sh`.  
2. Confirm only `BACKUPS_NUM` backups remain.  

### Restore Test:
1. Use `restore.sh` on a test directory.  
2. Validate restored files/databases.  

---

## Resources
- [PostgreSQL Backup Tools](https://selected.ru/blog/postgresql-backup-tools/)  
- [Bash Backup Example](https://github.com/AnonStar/home_backup)  
- [Cron Scheduling Guide](https://www.man7.org/linux/man-pages/man5/crontab.5.html) 

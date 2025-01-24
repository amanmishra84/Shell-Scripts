#!/bin/bash

# Variables for MySQL configuration
DB_USER="aman"               # MySQL username
DB_PASS=""       # MySQL password
DB_NAME="Hypha_Cohort"       # Name of the database to back up
BACKUP_DIR="/var/backups/mysql" # Directory to store backups
DATE=$(date +"%Y%m%d_%H%M%S")  # Date for backup file naming

# Ensure the backup directory exists
mkdir -p $BACKUP_DIR

# Function to perform database backup
backup_database() {
    BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$DATE.sql"
    echo "Starting backup for database: $DB_NAME"
    read -s -p  "Enter Password for $DB_USER: " DB_PASS
    mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE

    if [ $? -eq 0 ]; then
        echo "Backup successful! Compressing the backup file..."
        gzip $BACKUP_FILE
        echo "Backup compressed and saved at $BACKUP_FILE.gz"
    else
        echo "Backup failed!"
    fi
}

# Function to restore database from a backup file
restore_database() {
    read -p "Enter the path of the backup file to restore: " RESTORE_FILE

    if [ ! -f $RESTORE_FILE ]; then
        echo "Backup file not found: $RESTORE_FILE"
        exit 1
    fi
    db_name=$(basename "$RESTORE_FILE" | sed -E 's/_backup.*|\.sql\.gz//')
    
    # Check if the backup file is compressed
    if [[ $RESTORE_FILE == *.gz ]]; then
        echo "Decompressing the backup file..."
        gunzip -c $RESTORE_FILE > /tmp/$db_name.sql
        RESTORE_FILE="/tmp/$db_name.sql"
    fi

    echo "Database name extracted: $db_name"
    
    # Before restoring, check if the database exists
    read -s -p "Enter password for $DB_USER: " DB_PASS
    DB_EXISTS=$(mysql -u $DB_USER -p$DB_PASS -e "SHOW DATABASES LIKE '$db_name';" | grep "$db_name")
    if [ -z "$DB_EXISTS" ]; then
        echo "Database $db_name does not exist. Creating it..."
        mysql -u $DB_USER -p$DB_PASS -e "CREATE DATABASE $db_name;"
    fi

    # Proceed with restoration
    echo "Restoring database: $db_name from $RESTORE_FILE"
    mysql -u $DB_USER -p$DB_PASS $db_name < $RESTORE_FILE

    if [ $? -eq 0 ]; then
        echo "Restore successful!"
    else
        echo "Restore failed!"
    fi

    # Clean up temporary file if used
    if [ -f /tmp/restore_temp.sql ]; then
        rm /tmp/restore_temp.sql
    fi
}

# Menu for user to choose backup or restore
echo "MySQL Database Backup and Restore Script"
echo "---------------------------------------"
echo "1. Backup Database"
echo "2. Restore Database"
read -p "Enter your choice (1 or 2): " CHOICE

case $CHOICE in
    1)
        backup_database
        ;;
    2)
        restore_database
        ;;
    *)
        echo "Invalid choice! Exiting."
        ;;
esac


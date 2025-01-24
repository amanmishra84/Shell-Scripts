#!/bin/bash

# Define directories and filenames
LOG_DIR="/var/log"
BACKUP_DIR="/home/aman/log_backups"
DATE=$(date +\%Y\%m\%d\%H\%M)
LOG_FILE="$BACKUP_DIR/log_compression_report_$DATE.txt"
SUBJECT="Log Compression Report - $DATE"
ADMIN_EMAIL="amanmishra@gmail.com"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Start the log compression process
{
    echo "Log Compression Started at $(date)"

    # Compress all logs in the /var/log directory
    find $LOG_DIR -type f -name "*.log" | while read LOG_FILE_PATH
    do
        gzip -c $LOG_FILE_PATH > "$BACKUP_DIR/$(basename $LOG_FILE_PATH).$DATE.gz"
        if [ $? -eq 0 ]; then
            echo "Successfully compressed $LOG_FILE_PATH"
        else
            echo "Failed to compress $LOG_FILE_PATH"
        fi
    done

    # Delete logs older than 30 days in the backup directory
    find $BACKUP_DIR -type f -name "*.gz" -mtime +30 -exec rm -f {} \;
    echo "Deleted compressed logs older than 30 days"

    # Finish the script
    echo "Log Compression Finished at $(date)"
} > $LOG_FILE 2>&1

# Send email report to the admin
{
    echo "Subject: $SUBJECT"
    echo "To: $ADMIN_EMAIL"
    echo "Content-Type: text/plain; charset=UTF-8"
    echo " "
    cat $LOG_FILE
} | ssmtp "$ADMIN_EMAIL"

# Clean up the temporary log report file
rm -f $LOG_FILE


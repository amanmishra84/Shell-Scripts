#!/bin/bash

# Prompt the user to enter the partition to monitor
read -p "Enter the partition to monitor (e.g., /, /home): " PARTITION

# Check if the partition exists
if ! df -h "$PARTITION" &> /dev/null; then
    echo "Error: Partition '$PARTITION' does not exist."
    exit 1
fi

# Refresh interval in seconds
INTERVAL=60

# Function to display free disk space
check_disk_space() {
    # Get the available space in human-readable format
    FREE_SPACE=$(df -h "$PARTITION" | awk 'NR==2 {print $4}')
    
    # Print the free space with a timestamp
    echo "$(date): Available space on $PARTITION: $FREE_SPACE"
}

# Continuous monitoring loop
while true; do
    check_disk_space
    sleep $INTERVAL
done


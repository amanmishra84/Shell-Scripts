#!/bin/bash

# Prompt for the log file path
echo "Enter the path to the log file (e.g., /var/log/apache2/access.log):"
read LOGFILE

# Check if the log file exists
if [ ! -f "$LOGFILE" ]; then
    echo "Error: File '$LOGFILE' not found."
    exit 2
fi

# Function to analyze the log file
analyze_logs() {
    echo "Analyzing log file: $LOGFILE"
    echo ""

    # Top 5 most frequent IP addresses
    echo "Top 5 IP addresses:"
    awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -n 5
    echo ""

    # Top 5 requested URLs (excluding empty or malformed entries)
    echo "Top 5 requested URLs:"
    awk '{if ($7 != "-" && $7 ~ /^\//) print $7}' "$LOGFILE" | sort | uniq -c | sort -nr | head -n 5
    echo ""

    # Error codes (4xx and 5xx) and their counts
    echo "Error codes and their counts:"
    awk '{if ($9 ~ /^[45][0-9]{2}$/) print $9}' "$LOGFILE" | sort | uniq -c | sort -nr
    echo ""

    # HTTP status codes and their counts
    echo "All HTTP status codes and their counts:"
    awk '{if ($9 ~ /^[0-9]{3}$/) print $9}' "$LOGFILE" | sort | uniq -c | sort -nr
    echo ""
}

# Call the analysis function
analyze_logs















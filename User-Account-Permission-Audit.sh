#!/bin/bash

# Define sensitive directories to audit
DIRECTORIES=("/etc" "/var")

# Log file for audit report
LOGFILE="user_permission_audit.log"

# Ensure the log file is created
touch "$LOGFILE"

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOGFILE"
}

# Audit user accounts
audit_users() {
    log_message "Auditing user accounts..."
    echo -e "\nAll Users:" >> "$LOGFILE"
    cut -d: -f1 /etc/passwd | tee -a "$LOGFILE"

    echo -e "\nLast Login Information:" >> "$LOGFILE"
    lastlog | tee -a "$LOGFILE"
}

# Audit file permissions
audit_permissions() {
    log_message "Auditing file permissions in sensitive directories..."

    for DIR in "${DIRECTORIES[@]}"; do
        log_message "Checking directory: $DIR"

        # Find world-writable files
        log_message "World-writable files in $DIR:"
        find "$DIR" -type f -perm -0002 -exec ls -l {} \; 2>/dev/null | tee -a "$LOGFILE"

        # Find files without owner or group
        log_message "Files without owner or group in $DIR:"
        find "$DIR" \( -nouser -o -nogroup \) -exec ls -l {} \; 2>/dev/null | tee -a "$LOGFILE"
    done
}

# Main execution
log_message "Starting User Account and Permission Audit..."
audit_users
audit_permissions
log_message "Audit complete. Results saved in $LOGFILE."

exit 0


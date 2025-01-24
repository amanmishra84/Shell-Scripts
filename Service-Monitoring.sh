#!/bin/bash

# Define services to monitor
SERVICES=("apache2" "ssh" "mysql")

# Log file for service status changes
LOG_FILE="/var/log/service_monitor.log"

# Function to log the service status changes
log_status_change() {
    local service=$1
    local status=$2
    echo "$(date) - Service $service is $status" >> $LOG_FILE
}

# Function to restart the service
restart_service() {
    local service=$1
    sudo systemctl restart "$service"
    if [ $? -eq 0 ]; then
        log_status_change "$service" "restarted successfully"
        echo "Service $service restarted successfully."
    else
        log_status_change "$service" "failed to restart"
        echo "Failed to restart $service."
    fi
}

# Function to check services continuously
monitor_services() {
    while true; do
        # Loop through all services and check their status
        for service in "${SERVICES[@]}"; do
            # Check the current status of the service
            status=$(systemctl is-active "$service")

            if [ "$status" == "active" ]; then
                log_status_change "$service" "running"
                echo "Service $service is running."
            else
                log_status_change "$service" "down"
                echo "Service $service is down. Restarting..."
                restart_service "$service"
            fi
        done
        # Sleep for 10 seconds before checking again
        sleep 10
	clear
    done
}

# Start monitoring the services
monitor_services


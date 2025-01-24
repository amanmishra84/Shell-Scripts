#!/bin/bash

#Verify ssmtp installed or not
if ! command -v ssmtp &>/dev/null
then
    echo "ssmtp is not installed or not in the PATH. Please install and configure ssmtp."
    exit 1
fi

#configuration

LOGFILE="/var/log/network_health.log"
EMAIL="amanmishra658@gmail.com"
HOSTS=("198.128.2.1" "8.8.8.8" "192.168.1.1" "1.1.1.1" "google.com")
PING_COUNT=3
THRESHOLD=1

#Ensure the log file exists
touch "$LOGFILE"

#Function to log messages
log_message(){
	local message="$1"
	echo "$(date +'%Y-%m-%d %H:%M:%S') -$message" | tee -a "$LOGFILE"
}

#Function to send an email alert
send_alert(){
	local failed_hosts="$1"
	local subject="Network Health Alert: Issues Detected"
	local body="The following hosts failed to respond:\n$failed_hosts\n\nPlease investigate immediately.\n\nTimestamp: $(date)"
	echo -e "TO: $EMAIL \nSubject: $subject\n\n$body" | ssmtp "$EMAIL"
}

#Monitor network health

log_message "Starting network health check..."

FAILED_HOSTS=""
FAIL_COUNT=0

for HOST in "${HOSTS[@]}"
do
	log_message "Pinging $HOST..."
	if ! ping -c "$PING_COUNT" "$HOST" &>/dev/null;
	then
		log_message "ERROR: Failed to reach $HOST."
		FAILED_HOSTS+="$HOST\n"
		((FAIL_COUNT++))
		sleep 2
	else
		log_message "Success: $HOST is reachable."
		sleep 2
	fi
done
echo "$FAIL_COUNT"
echo "$FAILED_HOSTS"
#If failures exceed the threshold, send an alert
if [ "$FAIL_COUNT" -ge "$THRESHOLD" ]
then
	log_message "ALERT: $FAIL_COUNT host(s) failed. Sending mail to $EMAIL."
	send_alert "$FAILED_HOSTS"
else
	log_message "All checks passed or issues below threshold."
fi

log_message "Network health check complete."

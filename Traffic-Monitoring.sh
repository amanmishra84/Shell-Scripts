#!/bin/bash

#Verify ssmtp and vnstat installed or not
if ! command -v ssmtp &>/dev/null
then
    echo "ssmtp is not installed or not in the PATH. Please install and configure ssmtp."
    exit 1
fi

if ! command -v vnstat &>/dev/null
then
    echo "ssmtp is not installed or not in the PATH. Please install and configure ssmtp."
    exit 1
fi



# Configurations
INTERFACE="wlo1"              # Network interface to monitor (e.g., eth0, wlan0)
THRESHOLD_KB=100000           # Threshold in kB (e.g., 100000 kB = 100 MB)
ALERT_COUNT=3                 # Number of consecutive breaches before alert
LOG_FILE="/tmp/traffic.log"   # File to store traffic data
EMAIL="amanmishra@gmail.com"     # Email address for alerts

# Collect traffic stats using vnstat
TRAFFIC=$(vnstat --oneline | grep "$INTERFACE" | awk -F';' '{print $6}' | tr -d ' ')

# Extract numeric value and unit
VALUE=$(echo $TRAFFIC | grep -oE '^[0-9.]+')
UNIT=$(echo $TRAFFIC | grep -oE '[a-zA-Z]+$')

# Convert traffic value to kB based on unit
case $UNIT in
    "B")   VALUE_KB=$(echo "$VALUE / 1024" | bc);;
    "kB")  VALUE_KB=$VALUE;;
    "MB"|"MiB") VALUE_KB=$(echo "$VALUE * 1024" | bc);;
    "GB"|"GiB") VALUE_KB=$(echo "$VALUE * 1024 * 1024" | bc);;
    *) echo "Unknown unit: $UNIT"; exit 1;;
esac

# Persist traffic logs
echo "$(date): $VALUE_KB kB ($VALUE $UNIT)" >> $LOG_FILE

# Check if traffic exceeds the threshold
if (( $(echo "$VALUE_KB > $THRESHOLD_KB" | bc -l) )); then
    # Increment consecutive breach counter
    echo "1" >> /tmp/traffic_breach_count
else
    # Reset the counter if no breach
    > /tmp/traffic_breach_count
fi

# Check if the threshold is breached for three consecutive checks
BREACH_COUNT=$(wc -l < /tmp/traffic_breach_count)
if [[ $BREACH_COUNT -ge $ALERT_COUNT ]]; then
    # Send email alert
    subject="Network Traffic Alert"
    body="High network traffic detected on $INTERFACE Incoming traffic: $VALUE_KB kB ($VALUE $UNIT)"
    echo -e "TO: $EMAIL \nSubject: $subject\n\n$body" | ssmtp "$EMAIL"
    echo "Alert sent via email Successfully..."
    # Reset the counter after alerting
    > /tmp/traffic_breach_count
fi


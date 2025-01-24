#!/bin/bash

# Default refresh rate in seconds
REFRESH_RATE=3
MODE="simple"  # Default mode is simple (simple or detailed)

# Function to display CPU usage in a bar chart format
get_cpu_usage() {
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
    CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)
    echo "$CPU_USAGE"
}

# Function to display memory usage in a bar chart format
get_memory_usage() {
    MEM_INFO=$(free -m | awk 'NR==2 {print $3, $2}')
    MEM_USED=$(echo "$MEM_INFO" | awk '{print $1}')
    MEM_TOTAL=$(echo "$MEM_INFO" | awk '{print $2}')
    MEM_PERCENT=$(echo "scale=2; $MEM_USED / $MEM_TOTAL * 100" | bc)
    echo "$MEM_PERCENT"
}

# Function to display network usage in MB
get_network_usage() {
    NET_INTERFACE="wlo1"  # Change to your active network interface (e.g., eth0, wlan0)
    RX_CUR=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes)
    TX_CUR=$(cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes)
    RX_MB=$(echo "scale=2; $RX_CUR / 1024 / 1024" | bc)
    TX_MB=$(echo "scale=2; $TX_CUR / 1024 / 1024" | bc)
    echo "$RX_MB $TX_MB"
}

# Function to display the graphical bar chart using dialog
draw_graph() {
    local value=$1
    local max=$2
    local bar_length=40
    local bar_filled=$(echo "$value * $bar_length / $max" | bc)
    local bar_empty=$((bar_length - bar_filled))

    bar="["  # Start of the bar
    for ((i=0; i<$bar_filled; i++)); do bar="$bar#"; done
    for ((i=0; i<$bar_empty; i++)); do bar="$bar "; done
    bar="$bar]"

    echo "$bar"
}

# Function to display detailed system information
display_detailed_info() {
    CPU_USAGE=$(get_cpu_usage)
    MEM_USAGE=$(get_memory_usage)
    NETWORK_USAGE=$(get_network_usage)
    RX_MB=$(echo $NETWORK_USAGE | awk '{print $1}')
    TX_MB=$(echo $NETWORK_USAGE | awk '{print $2}')
    
    echo "Detailed System Resource Monitor"
    echo "CPU Usage: $CPU_USAGE% (Detailed)"
    echo "Memory Usage: $MEM_USAGE% (Used: $(free -m | awk 'NR==2 {print $3}') MB / Total: $(free -m | awk 'NR==2 {print $2}') MB)"
    echo "Network Usage: Received: $RX_MB MB, Sent: $TX_MB MB"
    echo
    echo "Press 'm' to switch to Simple Mode"
}

# Main monitoring loop
while true; do
    clear
    echo "Interactive System Resource Monitor"
    echo "Press 'Ctrl+C' to quit or 'm' to switch display mode."
    echo

    if [[ "$MODE" == "simple" ]]; then
        # Simple Mode - Just show the bar charts
        CPU_USAGE=$(get_cpu_usage)
        MEM_USAGE=$(get_memory_usage)
        NETWORK_USAGE=$(get_network_usage)
        RX_MB=$(echo $NETWORK_USAGE | awk '{print $1}')
        TX_MB=$(echo $NETWORK_USAGE | awk '{print $2}')
        
        echo "CPU Usage: $CPU_USAGE%"
        draw_graph $CPU_USAGE 100
        echo
        
        echo "Memory Usage: $MEM_USAGE%"
        draw_graph $MEM_USAGE 100
        echo
        
        echo "Network Usage: Received: $RX_MB MB, Sent: $TX_MB MB"
        echo

        # User input to switch mode or quit
        read -t $REFRESH_RATE -n 1 input
        if [[ "$input" == "q" ]]; then
            break
        elif [[ "$input" == "m" ]]; then
            MODE="detailed"
        fi

    elif [[ "$MODE" == "detailed" ]]; then
        # Detailed Mode - Show detailed information along with the graphical bars
        display_detailed_info

        # User input to switch mode or quit
        read -t $REFRESH_RATE -n 1 input
        if [[ "$input" == "q" ]]; then
            break
        elif [[ "$input" == "m" ]]; then
            MODE="simple"
        fi
    fi
done


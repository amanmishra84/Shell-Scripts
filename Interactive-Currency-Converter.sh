#!/bin/bash

API_KEY="b56c08501c652b6da0ff5164"

while true
do
    # Check if command-line arguments were provided
    if [[ -n "$1" && -n "$2" && -n "$3" ]]; then
        Entered_Currency="$1"
        Target_Currency="$2"
        Amount="$3"
    else
        # Interactive input if arguments are not provided
        read -p "Enter Base Currency: " Entered_Currency
        read -p "Enter Target Currency: " Target_Currency
        read -p "Enter Amount to be converted: " Amount
    fi

    # API call URL
    URL="https://v6.exchangerate-api.com/v6/${API_KEY}/pair/${Entered_Currency}/${Target_Currency}"
    RESPONSE=$(curl -s "$URL")

    # Check if response contains conversion rate
    if [[ $RESPONSE == *"conversion_rate"* ]]; then
        RATE=$(echo "$RESPONSE" | grep -oP '(?<="conversion_rate":)[0-9.]+')
        RESULT=$(echo "$Amount * $RATE" | bc -l)
        echo "Amount in $Target_Currency = $RESULT"
    else
        echo "Error fetching exchange rate. Please check your API key or input."
    fi

    # Ask if the user wants to continue
    read -p "Do you want to convert another amount? (yes/no): " CONTINUE
    if [[ "$CONTINUE" != "yes" ]]; then
        break
    fi

    # Clear arguments to switch to interactive mode for subsequent runs
    set --
done


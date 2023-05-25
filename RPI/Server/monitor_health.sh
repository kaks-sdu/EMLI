#!/bin/bash

# File where we'll log whether the internet is up and CPU temperature
LOG_FILE=/home/pi/EMLI/RPI/Server/log.csv

# Write header to the log file
echo "Timestamp,Internet Status,CPU Temperature" > $LOG_FILE

while true; do
    # Check internet connectivity
    if ping -c 1 8.8.8.8 &> /dev/null
    then
        INTERNET_STATUS="Up"
    else
        INTERNET_STATUS="Down"
    fi

    # Get CPU temperature
    CPU_TEMP=$(sensors | awk '/^temp1:/ {print $2}')

    # Write the data to the log file
    echo "$(date),${INTERNET_STATUS},${CPU_TEMP}" >> $LOG_FILE

    # Wait for one minute
    sleep 60
done

#!/bin/bash

# Configure the serial port
port="/dev/ttyACM0"  # Replace with the actual serial port device
baudrate=115200  # Replace with the baud rate of your serial communication

# Use stty to configure the serial port
stty -F $port $baudrate raw -echo   # the raw -echo options may help with some devices

# Use cat to read from the port and a while loop to process the data
cat $port | while read -r data
do
  if [ -n "$data" ]
  then
    echo "$data"
  fi
  sleep 1    # sleep for a second, simulating a timeout
done
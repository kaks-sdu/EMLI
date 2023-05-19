#!/bin/bash

# Get the port from command-line arguments
port="$1"
baudrate=115200

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
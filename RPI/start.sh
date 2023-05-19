#!/bin/bash

# Define the list of ports
ports=("/dev/ttyACM0") # ports=("/dev/ttyACM0" "/dev/ttyACM1" "/dev/ttyACM2")

# Start a child process for each port
pids=()
for port in "${ports[@]}"; do
    # Start a background process for each port
    # Pass the port as an argument to both scripts and pipe the output of read_serial.sh to control_pump.sh
    ./read_serial.sh "$port" | ./control_pump.sh "$port" &
    pids+=($!) # Store the PID of the subprocess
done

# Trap the SIGINT signal and kill child processes
trap 'kill ${pids[*]}' SIGINT

# Wait for all child processes to finish
wait

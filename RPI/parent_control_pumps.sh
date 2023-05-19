#!/bin/bash

# Define the list of ports
ports=("/dev/ttyACM0") # ports=("/dev/ttyACM0" "/dev/ttyACM1" "/dev/ttyACM2")

# Start a child process for each port
for port in "${ports[@]}"; do
    # Start a background process for each port
    # Pass the port as an argument to control_pump.sh
    ./control_pump.sh "$port" &
done

# Wait for all child processes to finish
wait

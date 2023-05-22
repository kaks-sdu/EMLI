#!/bin/bash

# Define the list of ports
ports=("/dev/ttyACM0")

# Trap the SIGINT signal and kill all child processes
trap cleanup SIGINT

cleanup() {
  # Kill all child processes
  kill $(jobs -p)
  exit
}

# Start a child process for each port
for port in "${ports[@]}"; do
  # Start a background process for each port
  # Pass the port as an argument to the scripts and split the output using tee
  ./read_serial.sh "$port" | tee >(./save_serial.sh) >(./control_pump.sh "$port") >(./mqtt_publish.sh "$port") >/dev/null &
done

# Wait for all child processes to finish
wait

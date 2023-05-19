#!/bin/bash

# Define the list of ports
ports=("/dev/ttyACM0")

# Trap the SIGINT signal and kill all child processes
trap cleanup SIGINT

cleanup() {
  # Kill all child processes
  kill $(jobs -p)

  # Remove the fifo files
  for port in "${ports[@]}"; do
    rm "$port.fifo"
  done
  exit
}

# Start a child process for each port
for port in "${ports[@]}"; do
  # Create a named pipe
  mkfifo "$port.fifo"

  # Start a background process for each port
  # Pass the port as an argument to the scripts and redirect the output of read_serial.sh to the named pipe
  ./read_serial.sh "$port" > "$port.fifo" &

  # Start control_pump.sh and mqtt_start_script.sh in background
  # Both scripts will read from the named pipe
  ./control_pump.sh "$port" < "$port.fifo" &
  ./mqtt_start_script.sh "$port" < "$port.fifo" &
done

# Wait for all child processes to finish
wait

#!/bin/bash

# Define the list of ports
ports=("/dev/ttyACM0")

cleanup() {
  # Kill all child processes
  kill $(jobs -p)

  # Remove the fifo files
  for port in "${ports[@]}"; do
    rm "${port}_fifo1"
    rm "${port}_fifo2"
  done
  exit
}

# Trap the SIGINT signal and call cleanup function
trap cleanup SIGINT

# Start a child process for each port
for port in "${ports[@]}"; do
  # Create two named pipes for each port
  mkfifo "${port}_fifo1"
  mkfifo "${port}_fifo2"

  # Start a background process for each port
  # Pass the port as an argument to the scripts and redirect the output of read_serial.sh to both named pipes
  ./read_serial.sh "$port" | tee "${port}_fifo1" > "${port}_fifo2" &

  # Start control_pump.sh and mqtt_start_script.sh in background
  # Each script will read from its own named pipe
  ./control_pump.sh "$port" < "${port}_fifo1" &
  ./mqtt_publish.sh "$port" < "${port}_fifo2" &
done

# Wait for all child processes to finish
wait


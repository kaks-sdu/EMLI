#!/bin/bash

# Define the list of ports
ports=("/dev/ttyACM0") # ports=("/dev/ttyACM0" "/dev/ttyACM1" "/dev/ttyACM2")

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

    # Remove the named pipe after use
    rm "$port.fifo"
done

# Trap the SIGINT signal and kill child processes
trap 'kill ${pids[*]}' SIGINT

# Wait for all child processes to finish
wait

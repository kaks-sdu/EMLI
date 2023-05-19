#!/bin/bash

# Configure the serial port
port="$1"
baudrate=115200

# Use stty to configure the serial port
stty -F $port $baudrate raw -echo   # the raw -echo options may help with some devices

while IFS=',' read -r pico_id plant_water_alarm pump_water_alarm moisture light
do
  # Remove carriage return characters
  pico_id=${pico_id//$'\r'/}
  plant_water_alarm=${plant_water_alarm//$'\r'/}
  pump_water_alarm=${pump_water_alarm//$'\r'/}
  moisture=${moisture//$'\r'/}
  light=${light//$'\r'/}

  echo "Received data: $pico_id,$plant_water_alarm,$pump_water_alarm,$moisture,$light"  # Print raw input data
done

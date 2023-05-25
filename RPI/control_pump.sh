#!/bin/bash

# Configure the serial port
port="$1"
threshold=50
pump_duration=1
alarm=0  # Indicator for alarm status 

# Initialize the timer
timer_start=$(date +%s)

while IFS=',' read -r pico_id plant_water_alarm pump_water_alarm moisture light
do
  # Remove carriage return characters
  pico_id=${pico_id//$'\r'/}
  plant_water_alarm=${plant_water_alarm//$'\r'/}
  pump_water_alarm=${pump_water_alarm//$'\r'/}
  moisture=${moisture//$'\r'/}
  light=${light//$'\r'/}

  echo "Received data: $pico_id,$plant_water_alarm,$pump_water_alarm,$moisture,$light"  # Print raw input data
  current_time=$(date +%s)
  time_elapsed=$((current_time - timer_start))

  # Check for alarms
  if [[ $plant_water_alarm -eq 1 ]] || [[ $pump_water_alarm -eq 1 ]]; then
    echo "Alarm! Plant water alarm: $plant_water_alarm, Pump water alarm: $pump_water_alarm"
    alarm=1
  else
    alarm=0
  fi

  # Run the pump every 12 hours
  if [[ $time_elapsed -ge 43200 ]] && [[ $alarm -eq 0 ]]; then
    echo -n 'p' > $port
    timer_start=$(date +%s)
    echo "run punp every 12h"
  fi

  # Run the pump once every hour if the soil moisture falls below a certain threshold
  if [[ $(bc <<< "$moisture < $threshold") -eq 1 ]] && [[ $(($time_elapsed % 3600)) -eq 0 ]] && [[ $alarm -eq 0 ]]; then
    echo -n 'p' > $port
    echo "moisture below threshold. starting pump"
  fi

done

#!/bin/bash

# Configure the serial port
port="$1"
threshold=30
pump_duration=1
alarm=0  # Indicator for alarm status 

# Initialize the timer and last received pico_id
timer_start=$(date +%s)
last_received_pico_id=""

broker="broker.hivemq.com"
qos=1
root="/kaks/"
topic_start_pump="start_pump"

# Start MQTT subscriber as a co-process
coproc mqtt_subscriber {
  mosquitto_sub -t "${root}$topic_start_pump" -h $broker -q $qos
}

# Assign the output file descriptor of the co-process to a variable
subscriber_fd=${mqtt_subscriber[0]}

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

  if ! kill -0 "$mqtt_subscriber_PID" 2>/dev/null; then
    echo "Restarting MQTT subscriber"
    coproc mqtt_subscriber {
      mosquitto_sub -t "${root}$topic_start_pump" -h $broker -q $qos
    }
    subscriber_fd=${mqtt_subscriber[0]}
  fi

  # Check for incoming MQTT messages
  if read -t 1 -u "$subscriber_fd" start_pump_message; then
    echo "Received MQTT message: $start_pump_message"
    if [[ $start_pump_message == $pico_id ]]; then
      echo -n 'p' > $port
      echo "Starting pump due to MQTT message"
      last_received_pico_id=$start_pump_message
    fi
  fi

  # Run the pump every 12 hours
  if [[ $time_elapsed -ge 43200 ]] && [[ $alarm -eq 0 ]]; then
    echo -n 'p' > $port
    timer_start=$(date +%s)
    echo "run pump every 12h"
  fi

  # Run the pump once every hour if the soil moisture falls below a certain threshold
  if [[ $(bc <<< "$moisture < $threshold") -eq 1 ]] && [[ $(($time_elapsed % 3600)) -eq 0 ]] && [[ $alarm -eq 0 ]]; then
    echo -n 'p' > $port
    echo "moisture below threshold. starting pump"
  fi

done

# Clean up the co-process
kill "$mqtt_subscriber_PID"

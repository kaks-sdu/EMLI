#!/bin/bash

broker="broker.hivemq.com"
qos=1
root="/kaks/"
topic_plant_water_alarm="plant_water_alarm"
topic_pump_water_alarm="pump_water_alarm"
topic_moisture="moisture"
topic_light="light"

while IFS=',' read -r pico_id plant_water_alarm pump_water_alarm moisture light
do
  # Remove carriage return characters
  pico_id=${pico_id//$'\r'/}
  plant_water_alarm=${plant_water_alarm//$'\r'/}
  pump_water_alarm=${pump_water_alarm//$'\r'/}
  moisture=${moisture//$'\r'/}
  light=${light//$'\r'/}

  mosquitto_pub -t "${root}$topic_plant_water_alarm" -m "${pico_id},${plant_water_alarm}" -h $broker -q $qos
  mosquitto_pub -t "${root}$topic_pump_water_alarm" -m "${pico_id},${pump_water_alarm}" -h $broker -q $qos
  mosquitto_pub -t "${root}$topic_moisture" -m "${pico_id},${moisture}" -h $broker -q $qos
  mosquitto_pub -t "${root}$topic_light" -m "${pico_id},${light}" -h $broker -q $qos
done

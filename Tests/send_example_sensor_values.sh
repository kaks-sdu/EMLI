#!/bin/bash

# System is OK
echo "1,0,0,35,100"
sleep 5
# Plant water alarm is running
echo "1,1,0,40,100"
sleep 5
# Pump water alarm is running
echo "1,0,1,90,100"
sleep 5
# Both alarms are running
echo "1,1,1,35,100"
sleep 5
# Moisture is below threshold
echo "1,0,0,1,100"
sleep 5
# System is back to OK
echo "1,0,0,35,100"

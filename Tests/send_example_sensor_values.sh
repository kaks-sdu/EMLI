#!/bin/bash

# Output some test data
for i in {1..10}
do
  echo "0,0,30,200"
  sleep 1
  echo "0,0,60,200"
  sleep 1
  echo "0,0,90,200"
  sleep 1
  echo "1,0,30,200"
  sleep 1
  echo "0,1,30,200"
  sleep 1
done

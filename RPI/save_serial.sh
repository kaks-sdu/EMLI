#!/bin/bash

output_file="./Server/output.csv"
date_format="%Y-%m-%d %H:%M:%S"

# Check if file exists
if [ ! -f "$output_file" ]; then
	touch "$output_file"
fi

# Save input
if [ -p /dev/stdin ]; then
	while IFS= read -r line; do
		timestamp=$(date +"$date_format")
		echo "$timestamp,$line" >> "$output_file"
	done
else
	while IFS= read -r line; do
		timestamp=$(date +"$date_format")
		echo "$timestamp,$line"
	done >> "$output_file"
fi

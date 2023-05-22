#!/bin/bash

iptables -F
iptables -t nat -F
iptables -t mangle -F

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

# Step 1: Get the name of the interface that provides internet access
ifconfig

echo "Please enter the name of the interface that provides internet access 
(e.g. wlan0):"
read interface_name

# Step 2: Enable IPv4 traffic forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# Step 3: Configure NAT to route packets from the RPi to the internet connection
sudo iptables -t nat -A POSTROUTING -o $interface_name -j MASQUERADE

echo "NAT configured to route packets from the RPi to the internet connection."

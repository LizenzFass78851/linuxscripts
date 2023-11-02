#!/bin/bash

# Set the terminal to full screen
printf '\e[?9h'

# Clear the terminal
clear

# Continuously display the current time
while true; do
    # Get the current time
    TIME=$(date +"%T")

    # Display the time in the center of the screen
    tput cup $(tput lines | awk '{print int($0/2)}') $((($(tput cols | awk '{print int($0/2)}') - 8)))
    echo $TIME

    # Wait for one second before updating the time again
    sleep 1
done

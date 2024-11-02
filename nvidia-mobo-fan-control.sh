#!/bin/bash

FAN_DEVICE="/sys/devices/platform/nct6687.2592/hwmon/hwmon5/pwm2"
INTERVAL=2  # Check every 2 seconds
MIN_TEMP=40
MAX_TEMP=75
MIN_SPEED=20
MAX_SPEED=254

# Function to calculate fan speed based on temperature
calculate_fan_speed() {
    local temp=$1
    local speed

    if [ "$temp" -lt "$MIN_TEMP" ]; then
        speed=$MIN_SPEED
    elif [ "$temp" -gt "$MAX_TEMP" ]; then
        speed=$MAX_SPEED
    else
        # Linear interpolation between min and max points
        local temp_range=$((MAX_TEMP - MIN_TEMP))
        local speed_range=$((MAX_SPEED - MIN_SPEED))
        local temp_delta=$((temp - MIN_TEMP))
        speed=$(( MIN_SPEED + (temp_delta * speed_range / temp_range) ))
    fi

    echo $speed
}

# Initialize previous speed
previous_speed=$MIN_SPEED

while true; do
    # Get GPU temperature
    output=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    temp=${output//[^0-9]/}

    # Calculate target speed
    target_speed=$(calculate_fan_speed $temp)

    # Implement different speeds for ramping up vs down
    if [ "$target_speed" -gt "$previous_speed" ]; then
        # Quick ramp up - go directly to target
        new_speed=$target_speed
    else
        # Slow ramp down - move only 1 step toward target
        if [ "$previous_speed" -gt "$target_speed" ]; then
            new_speed=$((previous_speed - 1))
        else
            new_speed=$target_speed
        fi
    fi

    # Set the fan speed
    echo $new_speed > "$FAN_DEVICE"
    previous_speed=$new_speed

    echo "Sent ${new_speed}"

    sleep $INTERVAL
done

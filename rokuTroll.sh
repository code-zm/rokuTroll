#!/bin/bash
# Simple bash script to find devices with port 8060 open on a local network (typically Roku devices).

# Display the header
echo "┌────────────────────────────────────────────────────────────────────────┐"
echo "│                   __            ______                   __    __      │ "
echo "│   _____  ____    / /__  __  __ /_  __/   _____  ____    / /   / /      │ "
echo "│  / ___/ / __ \\  / //_/ / / / /  / /     / ___/ / __ \\  / /   / /       │ "
echo "│ / /    / /_/ / / ,<   / /_/ /  / /     / /    / /_/ / / /   / /        │ "
echo "│/_/     \\____/ /_/|_|  \\__,_/  /_/     /_/     \\____/ /_/   /_/         │ "
echo "│                                                                        │ "
echo "└────────────────────────────────────────────────────────────────────────┘"
echo "┌────────────────────────────────────────────────────────────────────────┐"
echo "│    A simple tool to find Roku devices on a network and Rick Roll them. │ "
echo "└────────────────────────────────────────────────────────────────────────┘" 
echo "			CTRL+C to quit!"
echo

# Main Menu
echo "┌─────────────────────────────────────────────────────┐"
echo "│    How would you like to select the Roku device?    │"
echo "└─────────────────────────────────────────────────────┘"
echo " ├── [1] Enter IP Address Manually"
echo -e " └── [2] Scan the Network"
echo -n "      └─> "
read -r option 

# Option 1: Manual IP Entry
if [[ $option -eq 1 ]]; then
    echo
    echo "┌──────────────────────────────────────┐"
    echo "│    Enter the target's IP Address:    │"
    echo "└──────────────────────────────────────┘"
    echo -n "     └─> "
    read -r IP  

    # Check if the device is available
    echo " └── Checking if the device at $IP is available..." 	
    response=$(curl -s "http://$IP:8060/query/device-info")

    # Validate response
    if echo "$response" | grep -q "<device-info>"; then 		
        echo " └── Roku device found at $IP."
        
        # Extract name and location
        device_name=$(echo "$response" | grep -oPm1 "(?<=<user-device-name>)[^<]+")	
        device_location=$(echo "$response" | grep -oPm1 "(?<=<user-device-location>)[^<]+")

        # Set defaults if empty
        device_name="${device_name:-Unknown}"
        device_location="${device_location:-Unknown}"

        # Display device information
        echo " ├── $device_name, $device_location ($IP)" 	  

        # Prompt user to confirm continuation
        echo
        echo " └── Do you want to proceed with the Rick Roll?" 
        echo " ├── [1] Yes"
        echo -e " └── [2] No (Exit)"
        echo -n "      └─> "
        read -r confirm_option
        
        if [[ $confirm_option -eq 2 ]]; then
            echo " └── Exiting... Goodbye!"
            exit 0
        elif [[ $confirm_option -ne 1 ]]; then
            echo " └── Invalid option. Exiting..."
            exit 1
        fi
    else
        echo " └── No Roku device found at $IP. Exiting..."
        exit 1
    fi

# Option 2: Network Scan
elif [[ $option -eq 2 ]]; then 
    # Scan the network for devices with port 8060 open
    echo " └── Scanning the network for Roku devices on port 8060..." 	
    nmap_output=$(nmap -p 8060 --open 192.168.1.0/24 -oG - | grep "Ports: 8060/open" | awk '{print $2}')

    # Validate scan results
    if [[ -z "$nmap_output" ]]; then 
        echo " └── No Roku devices found."
        exit 1
    fi

    # Display found devices
    devices=($nmap_output)
    device_count=${#devices[@]}
    echo
    echo "┌───────────────────────────────────────────────────┐"
    echo "│    $device_count Roku device(s) found. Select a target:       │"
    echo "└───────────────────────────────────────────────────┘"
    
    # Arrays to hold device details
    device_names=()
    device_locations=()

    # Loop through each IP and display its details
    for i in "${!devices[@]}"; do 
        ip="${devices[$i]}"
        
        # Request device info
        response=$(curl -s "http://$ip:8060/query/device-info")

        # Extract name and location
        device_name=$(echo "$response" | grep -oPm1 "(?<=<user-device-name>)[^<]+") 	
        device_location=$(echo "$response" | grep -oPm1 "(?<=<user-device-location>)[^<]+") 

        # Set defaults if empty
        device_name="${device_name:-Unknown}"
        device_location="${device_location:-Unknown}"

        # Store details in arrays
        device_names+=("$device_name")
        device_locations+=("$device_location")

        device_index=$((i + 1))
        
        echo " ├──[$device_index] $device_name, $device_location ($ip)"
    done

    # Prompt user to select a device
    echo -n "     └─> "
    read -r selection
    selection=$((selection - 1))

    # Check if the selection is valid
    if [[ "$selection" -ge 0 && "$selection" -lt "$device_count" ]]; then
        IP="${devices[$selection]}"
        selected_name="${device_names[$selection]}"
        selected_location="${device_locations[$selection]}"
        echo " └── Selected device: ${selected_name}, ${selected_location} ($IP)"
        
        # Prompt user to confirm before continuing
        echo
        echo " └── Do you want to proceed with the Rick Roll?"
        echo " ├── [1] Yes"
        echo -e " └── [2] No (Exit)"
        echo -n "      └─> "
        read -r confirm_option
    
        if [[ $confirm_option -eq 2 ]]; then
            echo " └── Exiting... Goodbye!"
            exit 0
        elif [[ $confirm_option -ne 1 ]]; then
            echo " └── Invalid option. Exiting..."
            exit 1
        fi
    else
        echo " └── Invalid selection. Exiting..."
        exit 1
    fi
else
    echo " └── Invalid option. Exiting..."
    exit 1
fi

# Rick Roll Actions 
echo " └── Sending powerOn signal..."
curl -d '' "http://$IP:8060/keypress/powerOn"
sleep 3
curl -d '' "http://$IP:8060/keypress/home"
sleep 3
echo " └── Launching YouTube..."
curl -d '' "http://$IP:8060/launch/837" # launch YouTube
sleep 15
curl -d '' "http://$IP:8060/keypress/up"
sleep 1
echo " └── Searching for Rick Roll..."
curl -d '' "http://$IP:8060/keypress/select" # click search 
sleep 1
curl -d '' "http://$IP:8060/keypress/right"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/right"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/right"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/right"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/right"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/right"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/down"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/select" # click n
sleep 0.15
curl -d '' "http://$IP:8060/keypress/left"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/left"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/up"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/select" # click e
sleep 0.15
curl -d '' "http://$IP:8060/keypress/left"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/left"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/left"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/left"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/down"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/down"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/down"
sleep 0.15
curl -d '' "http://$IP:8060/keypress/select" # click v
sleep 0.15
curl -d '' "http://$IP:8060/keypress/left" # go to quick search
sleep 0.15
curl -d '' "http://$IP:8060/keypress/select"
echo " └── Rick Roll initiated, maxing out volume..."
sleep 1
curl -d '' "http://$IP:8060/keypress/right"
sleep 0.125
for _ in {1..100}; do
  curl -d '' "http://$IP:8060/keypress/volumeup"
  sleep 0.05
done
echo " └── Rick Roll complete."


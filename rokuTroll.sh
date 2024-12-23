#!/bin/bash
# bash script to find devices with port 8060 open on a local network (typically Roku devices) and rick roll them. 

# display the header
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

# get the ip address and subnet in cidr format dynamically
cidr=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n 1)

# extract ip and prefix length
ip=$(echo $cidr | cut -d'/' -f1)
prefix=$(echo $cidr | cut -d'/' -f2)

# calculate the network address
IFS=. read -r i1 i2 i3 i4 <<< "$ip"
mask=$((0xffffffff << (32 - prefix) & 0xffffffff))
n1=$((i1 & (mask >> 24)))
n2=$((i2 & (mask >> 16 & 0xff)))
n3=$((i3 & (mask >> 8 & 0xff)))
n4=$((i4 & (mask & 0xff)))

# format the output as network/prefix
network="$n1.$n2.$n3.$n4/$prefix"

# option 1: manual ip entry
if [[ $option -eq 1 ]]; then
    echo
    echo "┌──────────────────────────────────────┐"
    echo "│    Enter the target's IP Address:    │"
    echo "└──────────────────────────────────────┘"
    echo -n "     └─> "
    read -r IP  

    # check if the device is available
    echo " └── Checking if the device at $IP is available..." 	
    response=$(curl -s "http://$IP:8060/query/device-info")

    # validate response
    if echo "$response" | grep -q "<device-info>"; then 		
        echo " └── Roku device found at $IP."
        
        # extract name and location
        deviceName=$(echo "$response" | grep -oPm1 "(?<=<user-device-name>)[^<]+")	
        deviceLocation=$(echo "$response" | grep -oPm1 "(?<=<user-device-location>)[^<]+")

        # set defaults if empty
        deviceName="${deviceName:-Unknown}"
        deviceLocation="${deviceLocation:-Unknown}"

        # display device information
        echo " ├── $deviceName, $deviceLocation ($IP)" 	  

        # prompt user to confirm continuation
        echo
        echo " └── Do you want to proceed with the Rick Roll?" 
        echo " ├── [1] Yes"
        echo -e " └── [2] No (Exit)"
        echo -n "      └─> "
        read -r confirmOption
        
        if [[ $confirmOption -eq 2 ]]; then
            echo " └── Exiting... Goodbye!"
            exit 0
        elif [[ $confirmOption -ne 1 ]]; then
            echo " └── Invalid option. Exiting..."
            exit 1
        fi
    else
        echo " └── No Roku device found at $IP. Exiting..."
        exit 1
    fi

# option 2: network scan
elif [[ $option -eq 2 ]]; then 
    # scan the network for devices with port 8060 open
    echo " └── Scanning $network for Roku devices on port 8060..." 	
    nmapOutput=$(nmap -p 8060 --open "$network" -oG - | grep "Ports: 8060/open" | awk '{print $2}')

    # validate scan results
    if [[ -z "$nmapOutput" ]]; then 
        echo " └── No Roku devices found."
        exit 1
    fi

    # display found devices
    devices=($nmapOutput)
    deviceCount=${#devices[@]}
    echo
    echo "┌───────────────────────────────────────────────────┐"
    echo "│    $deviceCount Roku device(s) found. Select a target:       │"
    echo "└───────────────────────────────────────────────────┘"
    
    # arrays to hold device details
    deviceNames=()
    deviceLocations=()

    # loop through each ip and display its details
    for i in "${!devices[@]}"; do 
        ip="${devices[$i]}"
        
        # request device info
        response=$(curl -s "http://$ip:8060/query/device-info")

        # extract name and location
        deviceName=$(echo "$response" | grep -oPm1 "(?<=<user-device-name>)[^<]+") 	
        deviceLocation=$(echo "$response" | grep -oPm1 "(?<=<user-device-location>)[^<]+") 

        # set defaults if empty
        deviceName="${deviceName:-Unknown}"
        deviceLocation="${deviceLocation:-Unknown}"

        # store details in arrays
        deviceNames+=("$deviceName")
        deviceLocations+=("$deviceLocation")

        deviceIndex=$((i + 1))
        
        echo " ├──[$deviceIndex] $deviceName, $deviceLocation ($ip)"
    done

    # prompt user to select a device
    echo -n "     └─> "
    read -r selection
    selection=$((selection - 1))

    # check if the selection is valid
    if [[ "$selection" -ge 0 && "$selection" -lt "$deviceCount" ]]; then
        IP="${devices[$selection]}"
        selectedName="${deviceNames[$selection]}"
        selectedLocation="${deviceLocations[$selection]}"
        echo " └── Selected device: ${selectedName}, ${selectedLocation} ($IP)"
        
        # prompt user to confirm before continuing
        echo
        echo " └── Do you want to proceed with the Rick Roll?"
        echo " ├── [1] Yes"
        echo -e " └── [2] No (Exit)"
        echo -n "      └─> "
        read -r confirmOption
    
        if [[ $confirmOption -eq 2 ]]; then
            echo " └── Exiting... Goodbye!"
            exit 0
        elif [[ $confirmOption -ne 1 ]]; then
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

# rick roll actions 
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
for  in {1..100}; do
  curl -d '' "http://$IP:8060/keypress/volumeup"
  sleep 0.05
done
echo " └── Rick Roll complete."

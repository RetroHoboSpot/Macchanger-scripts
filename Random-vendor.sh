#!/bin/bash

# List of MAC address vendor prefixes embedded directly in the script
VENDOR_MAC_PREFIXES=$(cat <<EOF
# Apple Inc.
00:17:F2    # Apple
00:1E:C2    # Apple
D0:5E:A6    # Apple
F4:1F:8A    # Apple

# Samsung Electronics
00:1A:2B    # Samsung
00:1D:92    # Samsung
00:14:22    # Samsung

# Intel Corporation
00:1B:21    # Intel
00:23:DF    # Intel
00:1F:29    # Intel

# Microsoft Corporation
00:50:56    # Microsoft
00:0C:29    # Microsoft
00:15:5D    # Microsoft

# Cisco Systems, Inc.
00:1B:1C    # Cisco
00:40:96    # Cisco
00:00:0C    # Cisco

# Dell Inc.
00:14:22    # Dell
00:21:9B    # Dell
00:19:D1    # Dell

# Sony Corporation
00:21:91    # Sony
00:18:E7    # Sony
00:22:15    # Sony

# Broadcom Limited
00:1E:8C    # Broadcom
00:11:22    # Broadcom
00:14:BF    # Broadcom

# TP-Link Technologies Co., Ltd.
00:1A:A0    # TP-Link
60:67:20    # TP-Link

# Huawei Technologies Co., Ltd.
00:1D:8C    # Huawei
00:1F:90    # Huawei
28:3A:4D    # Huawei

# Motorola Solutions, Inc.
00:05:9A    # Motorola
00:11:32    # Motorola
00:09:4B    # Motorola

# Panasonic Corporation
00:18:0A    # Panasonic
00:1F:B2    # Panasonic

# Lenovo (Beijing) Ltd.
00:16:36    # Lenovo
00:21:6A    # Lenovo

# Atheros Communications, Inc. (Now part of Qualcomm)
00:04:96    # Atheros
00:1C:10    # Atheros

# LG Electronics
00:1E:D1    # LG Electronics
00:1C:77    # LG Electronics

# ASUS Computer Inc.
00:1A:70    # ASUS
00:24:8C    # ASUS
EOF
)

# Function to generate random MAC address based on vendor prefix
generate_random_mac() {
    # Generate random hex pairs for the last 3 pairs of the MAC address (6 bytes total)
    HEX_PAIR=$(od -An -N3 -t x1 /dev/urandom | tr -d ' \n' | sed 's/\(..\)/\1:/g; s/:$//')
    echo "$HEX_PAIR"
}

# Function to list network interfaces and allow the user to choose
select_interface() {
    # List all available network interfaces
    echo "Available network interfaces:"
    INTERFACES=$(ip link show | grep -oP '^\d+: \K\w+' | grep -vE 'lo|docker|br-|veth')  # Exclude loopback and virtual interfaces
    select INTERFACE in $INTERFACES; do
        if [[ -n "$INTERFACE" ]]; then
            echo "You selected: $INTERFACE"
            break
        else
            echo "Invalid selection. Please choose a valid interface."
        fi
    done
}

# Check if the vendor list is empty
if [ -z "$VENDOR_MAC_PREFIXES" ]; then
    echo "No vendor MAC address prefixes available."
    exit 1
fi

# List and select network interface
select_interface

# Randomly choose a vendor prefix from the embedded list
VENDOR_PREFIX=$(echo "$VENDOR_MAC_PREFIXES" | grep -oP '^\S{2}:\S{2}:\S{2}' | shuf -n 1)

# Generate the random suffix for the MAC address
RANDOM_SUFFIX=$(generate_random_mac)

# Combine vendor prefix with the random suffix to form the new MAC address
NEW_MAC="$VENDOR_PREFIX:$RANDOM_SUFFIX"

# Display the new MAC address
echo "New MAC Address: $NEW_MAC"

# Disable the network interface before changing the MAC address
echo "Disabling network interface $INTERFACE..."
sudo ifconfig "$INTERFACE" down || { echo "Failed to bring down $INTERFACE"; exit 1; }

# Change the MAC address using macchanger
echo "Changing MAC address for $INTERFACE..."
sudo macchanger -m "$NEW_MAC" "$INTERFACE" || { echo "Failed to change MAC address"; exit 1; }

# Enable the network interface again
echo "Enabling network interface $INTERFACE..."
sudo ifconfig "$INTERFACE" up || { echo "Failed to bring up $INTERFACE"; exit 1; }

# Display the new MAC address using macchanger (for verification)
echo "MAC address of $INTERFACE changed to $NEW_MAC"

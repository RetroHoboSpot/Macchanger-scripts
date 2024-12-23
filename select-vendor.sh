#!/bin/bash

# List of MAC address vendor prefixes embedded directly in the script
VENDOR_MAC_PREFIXES=$(cat <<EOF
Apple:00:17:F2
Apple:00:1E:C2
Apple:D0:5E:A6
Apple:F4:1F:8A
Samsung:00:1A:2B
Samsung:00:1D:92
Samsung:00:14:22
Intel:00:1B:21
Intel:00:23:DF
Intel:00:1F:29
Microsoft:00:50:56
Microsoft:00:0C:29
Microsoft:00:15:5D
Cisco:00:1B:1C
Cisco:00:40:96
Cisco:00:00:0C
Dell:00:14:22
Dell:00:21:9B
Dell:00:19:D1
Sony:00:21:91
Sony:00:18:E7
Sony:00:22:15
Broadcom:00:1E:8C
Broadcom:00:11:22
Broadcom:00:14:BF
TP-Link:00:1A:A0
TP-Link:60:67:20
Huawei:00:1D:8C
Huawei:00:1F:90
Huawei:28:3A:4D
Motorola:00:05:9A
Motorola:00:11:32
Motorola:00:09:4B
Panasonic:00:18:0A
Panasonic:00:1F:B2
Lenovo:00:16:36
Lenovo:00:21:6A
Atheros:00:04:96
Atheros:00:1C:10
LG:00:1E:D1
LG:00:1C:77
ASUS:00:1A:70
ASUS:00:24:8C
EOF
)

# Function to generate random MAC suffix
generate_random_mac_suffix() {
    od -An -N3 -t x1 /dev/urandom | tr -d ' \n' | sed 's/\(..\)/\1:/g; s/:$//'
}

# Function to select vendor
select_vendor() {
    echo "Available Vendors:"
    VENDORS=$(echo "$VENDOR_MAC_PREFIXES" | cut -d: -f1 | sort | uniq)
    select VENDOR in $VENDORS; do
        if [[ -n "$VENDOR" ]]; then
            echo "You selected vendor: $VENDOR"
            break
        else
            echo "Invalid selection. Please choose a valid vendor."
        fi
    done
}

# Function to select interface
select_interface() {
    echo "Available network interfaces:"
    INTERFACES=$(ip link show | grep -oP '^\d+: \K\w+' | grep -vE 'lo|docker|br-|veth')  # Exclude loopback and virtual interfaces
    select INTERFACE in $INTERFACES; do
        if [[ -n "$INTERFACE" ]]; then
            echo "You selected interface: $INTERFACE"
            break
        else
            echo "Invalid selection. Please choose a valid interface."
        fi
    done
}

# Ensure the vendor list is not empty
if [ -z "$VENDOR_MAC_PREFIXES" ]; then
    echo "No vendor MAC address prefixes available."
    exit 1
fi

# Select vendor
select_vendor

# Filter prefixes for the selected vendor
VENDOR_PREFIXES=$(echo "$VENDOR_MAC_PREFIXES" | grep "^$VENDOR" | cut -d: -f2-)

# Randomly select a prefix for the chosen vendor
VENDOR_PREFIX=$(echo "$VENDOR_PREFIXES" | shuf -n 1)

# Select interface
select_interface

# Generate the random suffix for the MAC address
RANDOM_SUFFIX=$(generate_random_mac_suffix)

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

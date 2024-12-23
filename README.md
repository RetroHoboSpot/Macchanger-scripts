# MAC Address Randomizer Script

## Overview

This repository contains two bash scripts for generating and assigning randomized MAC addresses to network interfaces. These scripts use predefined vendor-specific MAC address prefixes (Organizationally Unique Identifiers, or OUIs) to generate valid MAC addresses, enhancing privacy and bypassing network restrictions.

### Features
- **Embedded Vendor Prefixes**:
  - Includes MAC address prefixes for major vendors like Apple, Samsung, Intel, and more.
- **Random MAC Address Generation**:
  - Creates a valid MAC address by combining a vendor prefix with a random suffix.
- **Network Interface Management**:
  - Allows users to select a network interface for which the MAC address will be changed.
- **Interactive Vendor Selection** *(Second Script)*:
  - Users can choose a specific vendor, ensuring the generated MAC matches the selected brand.
- **Error Handling**:
  - Includes checks for valid selections and graceful handling of command failures.

---

## Scripts

### 1. **Script 1: Auto-Select Vendor and Interface**
- This script automatically:
  - Randomly selects a vendor prefix.
  - Displays available network interfaces for user selection.
  - Generates a new MAC address and applies it to the selected interface.

### 2. **Script 2: User-Selected Vendor and Interface**
- This script offers:
  - An interactive menu to select a vendor from the list.
  - A separate menu to select a network interface.
  - The MAC address is generated using the selected vendor's prefix.

---

## Requirements
- **macchanger**:
  - Ensure `macchanger` is installed on your system. Install it using:
    ```bash
    sudo apt-get install macchanger
    ```
- **Root Privileges**:
  - The scripts require `sudo` to disable interfaces and change MAC addresses.

---

## How to Use

1. Clone this repository:
   ```bash
   git clone https://github.com/RetroHoboSpot/Macchanger-scripts.git
   cd Macchanger-scripts

2. Make it Exacutable

   ```bash
   chmod +x Random-vendor.sh select-vendor.sh
3. Runnnnnn
  Select Vendor 
   ```bash
   sudo ./select-vendor.sh

Just send it and random Mac 
   ```bash
   sudo ./Random-vendor.sh
   

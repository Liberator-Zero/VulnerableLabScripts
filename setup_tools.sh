#!/bin/bash

# Function to check and install a package
check_and_install() {
    PACKAGE=$1
    if dpkg -l | grep -q "^ii  $PACKAGE "; then
        echo "$PACKAGE is already installed."
    else
        echo "$PACKAGE is not installed. Installing..."
        sudo apt-get update -y
        sudo apt-get install -y $PACKAGE
    fi
}

# List of packages to check and install
PACKAGES=("openssh-server" "fail2ban" "auditd" "audispd-plugins")

for PACKAGE in "${PACKAGES[@]}"; do
    check_and_install $PACKAGE
done

echo "All specified packages have been checked and installed if necessary."

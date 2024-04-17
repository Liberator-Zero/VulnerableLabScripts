#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Update system and install tools
echo "Updating system and installing security tools..."

# Update package list and upgrade all packages
apt-get update && apt-get upgrade -y

# Install network analysis tools
echo "Installing network analysis tools..."
apt-get install -y nmap wireshark tcpdump

# Install vulnerability assessment tools
echo "Installing vulnerability assessment tools..."
apt-get install -y nikto openvas

# Install penetration testing tools
echo "Installing penetration testing tools..."
apt-get install -y metasploit-framework

# Install intrusion detection systems
echo "Installing intrusion detection systems..."
apt-get install -y snort

# Install system auditing tools
echo "Installing system auditing tools..."
apt-get install -y lynis chkrootkit

# Install log management tools
echo "Installing log management tools..."
apt-get install -y logwatch

# Install additional useful tools
echo "Installing additional useful tools..."
apt-get install -y htop iftop iotop

# Install Python 3 and Scapy
echo "Installing Python 3 and Scapy..."
apt-get install -y python3 python3-pip
pip3 install scapy

# Install C Compiler and development tools
echo "Installing C Compiler and development tools..."
apt-get install -y build-essential gcc make

echo "All selected security tools, development tools, and Python 3 with Scapy have been installed successfully."

# Configure tools that require additional setup
echo "Configuring tools..."

# Configure Wireshark for non-root user (if necessary)
getent group wireshark || groupadd wireshark
usermod -a -G wireshark $USER
setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap
echo "Wireshark configured to allow non-root user."

echo "Installing advanced system monitoring tools..."
apt-get install -y glances
bash <(curl -Ss https://my-netdata.io/kickstart.sh)  # Install netdata

echo "Installing security auditing tools..."
apt-get install -y auditd rkhunter

echo "Installing file integrity tools..."
apt-get install -y aide
aideinit

echo "Installing backup tools..."
apt-get install -y rsync duplicity

echo "Installing binary analysis tools..."
apt-get install -y binwalk radare2

echo "Installing advanced file management tools..."
apt-get install -y ncdu tree

echo "Installing system rescue and recovery tools..."
apt-get install -y testdisk foremost

echo "Installation and configuration complete. Please reboot for all changes to take effect."
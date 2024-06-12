#!/bin/bash

# Function to create admin accounts
create_admin_account() {
    read -p "Enter the admin username: " username
    sudo adduser $username
    sudo usermod -aG sudo $username
    sudo passwd -l $username

    # Locking down SSH access
    echo "DenyUsers $username" | sudo tee -a /etc/ssh/sshd_config
    sudo systemctl reload sshd

    echo "Admin account $username created and SSH access disabled."
}

# Main script
while true; do
    create_admin_account
    read -p "Do you want to create another admin account? (y/n): " choice
    if [[ $choice != [Yy]* ]]; then
        break
    fi
done

echo "All requested admin accounts have been created and configured."

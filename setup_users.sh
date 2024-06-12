#!/bin/bash

create_user() {
  # Prompt for username
  read -p "Enter the username: " USERNAME

  # Prompt for SSH passphrase
  read -s -p "Enter the SSH passphrase: " SSHPASSPHRASE
  echo

  # Variables
  HOME_DIR="/home/$USERNAME"
  SHELL="/usr/local/bin/restricted_shell.sh"

  # Create a new user with a home directory
  useradd -m -s $SHELL $USERNAME

  # Set a password for the user (you can automate this or set it manually)
  echo "Set a password for $USERNAME"
  passwd $USERNAME

  # Generate SSH key pair with passphrase
  mkdir -p $HOME_DIR/.ssh
  ssh-keygen -f $HOME_DIR/.ssh/id_rsa -N "$SSHPASSPHRASE" -C "$USERNAME@$(hostname)"
  chown -R $USERNAME:$USERNAME $HOME_DIR/.ssh
  chmod 700 $HOME_DIR/.ssh
  chmod 600 $HOME_DIR/.ssh/id_rsa

  # Copy the public key to authorized_keys
  cat $HOME_DIR/.ssh/id_rsa.pub > $HOME_DIR/.ssh/authorized_keys
  chmod 600 $HOME_DIR/.ssh/authorized_keys
  chown $USERNAME:$USERNAME $HOME_DIR/.ssh/authorized_keys

  # Update the user's home directory in the primary /etc/passwd
  sed -i "s|^$USERNAME:.*|$USERNAME:x:$(id -u $USERNAME):$(id -g $USERNAME):,,,:$HOME_DIR:$SHELL|" /etc/passwd

  # Remove any NOPASSWD directive for the user from the sudoers file
  sed -i "/$USERNAME ALL=(ALL) NOPASSWD: \/bin\/su/d" /etc/sudoers

  # Update sshd_config to restrict the user
  if ! grep -q "Match User $USERNAME" /etc/ssh/sshd_config; then
    cat <<EOL >> /etc/ssh/sshd_config

Match User $USERNAME
    ForceCommand /usr/local/bin/restricted_shell.sh
    AllowTcpForwarding no
    X11Forwarding no
    PermitTunnel no
    AllowAgentForwarding no
EOL
  fi

  systemctl restart sshd

  echo "User $USERNAME has been created successfully."
}

# Create restricted shell script
cat <<'EOF' > /usr/local/bin/restricted_shell.sh
#!/bin/bash
# Restricted shell script

echo "You have limited access. Type 'su <admin_user>' to switch to the admin account."

while true; do
  read -p "$USER@$(hostname): " cmd
  if [[ $cmd == su* ]]; then
    eval $cmd
  else
    echo "Access Denied: You can only use the 'su' command."
  fi
done
EOF

chmod +x /usr/local/bin/restricted_shell.sh

# Main loop to create users
while true; do
  create_user
  
  read -p "Do you want to create another user? (y/n): " choice
  case "$choice" in 
    y|Y ) continue;;
    n|N ) break;;
    * ) echo "Invalid input, please enter y or n";;
  esac
done

echo "User creation process completed."

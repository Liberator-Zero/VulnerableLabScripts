#!/bin/bash

# Function to configure SSH settings

configure_ssh_settings() {
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  # Use sed to update or append the necessary settings
  sudo sed -i '/^Port /c\Port 6969' /etc/ssh/sshd_config
  sudo sed -i '/^PermitRootLogin /c\PermitRootLogin no' /etc/ssh/sshd_config
  sudo sed -i '/^PasswordAuthentication /c\PasswordAuthentication no' /etc/ssh/sshd_config
  sudo sed -i '/^ChallengeResponseAuthentication /c\ChallengeResponseAuthentication no' /etc/ssh/sshd_config
  sudo sed -i '/^UsePAM /c\UsePAM yes' /etc/ssh/sshd_config
  sudo sed -i '/^MaxAuthTries /c\MaxAuthTries 3' /etc/ssh/sshd_config
  sudo sed -i '/^LoginGraceTime /c\LoginGraceTime 1m' /etc/ssh/sshd_config
  sudo sed -i '/^ClientAliveInterval /c\ClientAliveInterval 300' /etc/ssh/sshd_config
  sudo sed -i '/^ClientAliveCountMax /c\ClientAliveCountMax 0' /etc/ssh/sshd_config

  # Allow specific users to SSH
  sudo sed -i '/^AllowUsers /c\AllowUsers brett jeffery christopher' /etc/ssh/sshd_config

  # If any of the above settings are not present, append them to the file
  grep -qxF 'Port 6969' /etc/ssh/sshd_config || echo 'Port 6969' | sudo tee -a /etc/ssh/sshd_config
  grep -qxF 'PermitRootLogin no' /etc/ssh/sshd_config || echo 'PermitRootLogin no' | sudo tee -a /etc/ssh/sshd_config
  grep -qxF 'PasswordAuthentication no' /etc/ssh/sshd_config || echo 'PasswordAuthentication no' | sudo tee -a /etc/ssh/sshd_config
  grep -qxF 'ChallengeResponseAuthentication no' /etc/ssh/sshd_config || echo 'ChallengeResponseAuthentication no' | sudo tee -a /etc/ssh/sshd_config
  grep -qxF 'UsePAM yes' /etc/ssh/sshd_config || echo 'UsePAM yes' | sudo tee -a /etc/ssh/sshd_config
  grep -qxF 'MaxAuthTries 3' /etc/ssh/sshd_config || echo 'MaxAuthTries 3' | sudo tee -a /etc/ssh/sshd_config
  grep -qxF 'LoginGraceTime 1m' /etc/ssh/sshd_config || echo 'LoginGraceTime 1m' | sudo tee -a /etc/ssh/sshd_config
  grep -qxF 'ClientAliveInterval 300' /etc/ssh/sshd_config || echo 'ClientAliveInterval 300' | sudo tee -a /etc/ssh/sshd_config
  grep -qxF 'ClientAliveCountMax 0' /etc/ssh/sshd_config || echo 'ClientAliveCountMax 0' | sudo tee -a /etc/ssh/sshd_config
  grep -qxF 'AllowUsers brett jeffery christopher' /etc/ssh/sshd_config || echo 'AllowUsers brett jeffery christopher' | sudo tee -a /etc/ssh/sshd_config

  sudo systemctl restart sshd
}

# Function to configure Fail2Ban
configure_fail2ban() {
  sudo bash -c 'cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = 6969
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
EOF'
  sudo systemctl enable fail2ban
  sudo systemctl restart fail2ban
}

# Function to disable direct root login
disable_root_login() {
  sudo passwd -l root
  echo "Root account login disabled."
}

# Function to configure auditd for SSH monitoring
configure_auditd() {
  sudo bash -c 'cat > /etc/audit/rules.d/audit.rules << EOF
-w /etc/ssh/sshd_config -p wa -k sshd_config_changes
-w /var/log/auth.log -p wa -k auth_log
-w /home/ -p wa -k user_home
EOF'
  sudo systemctl restart auditd
}

# Configure SSH settings
configure_ssh_settings

# Configure Fail2Ban
configure_fail2ban

# Disable direct root login
disable_root_login

# Configure auditd for SSH monitoring
configure_auditd

echo "Initial setup complete. Additional security measures applied."

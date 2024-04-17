#!/bin/bash

# Array of example real names
names=("Alice Johnson" "Bob Smith" "Carol Danvers" "David Banner" "Eve Polastri" "Frank Castle" "Grace Hopper" "Harry Potter" "Ivy Doe" "John Snow")

# Ensure SSH is installed and running
if ! which sshd > /dev/null; then
    echo "SSH server is not installed. Installing now."
    apt-get update && apt-get install -y openssh-server
else
    echo "SSH server is already installed."
fi

# Create user accounts with unique weak passwords
for i in "${!names[@]}"; do
    username=$(echo "${names[i]}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    # Generate a unique weak password for each user
    weak_password="password$i!23"
    useradd -m -p $(openssl passwd -1 $weak_password) $username
    
    # Assign specific privileges
    case $i in
        0|1) # First two users with sudo permissions
            usermod -aG sudo $username
            ;;
        3) # Fourth user can sudo nano without password
            echo "$username ALL=(ALL) NOPASSWD: /usr/bin/nano" >> /etc/sudoers
            ;;
    esac
done

# Randomly assign one user to have misconfigured scp access without sudo
random_user=$((RANDOM % 10))
scp_user=${names[$random_user]}
scp_username=$(echo "$scp_user" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

# Adding user to the sshd_config for misconfigured SCP
echo "AllowUsers $scp_username" >> /etc/ssh/sshd_config
echo "$scp_username has been misconfigured for SCP access."

# Configure root account with a weak password and enable SSH root login
echo "root:rootpassword123" | chpasswd
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Generate SSH keys for root
mkdir /root/.ssh
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''

# Restart SSH service to apply changes
systemctl restart sshd

echo "Root account is configured with weak password and SSH access enabled. Keys generated."

# Create backupaccount with home directory and bash shell
useradd -m -d /home/backupaccount -s /bin/bash backupaccount
echo "backupaccount:backuppassword" | chpasswd

# Generate SSH keys for backupaccount
mkdir /home/backupaccount/.ssh
ssh-keygen -f /home/backupaccount/.ssh/id_rsa -t rsa -N ''
chown -R backupaccount:backupaccount /home/backupaccount/.ssh

# Create and configure /backups/ directory
mkdir /backups
mkdir /backups/log_backups
mkdir /backups/data_backups
chown -R backupaccount:backupaccount /backups
chmod -R 700 /backups

echo "Backupaccount configured with its own SSH keys and a secure backup directory structure."

# Create the globally writable script opcheck.sh
echo '#!/bin/bash' > /usr/local/bin/opcheck.sh
echo 'if ping -c 1 google.com; then echo "Ping success"; else echo "Ping failure"; fi' >> /usr/local/bin/opcheck.sh
chmod +x /usr/local/bin/opcheck.sh
chmod 777 /usr/local/bin/opcheck.sh

# Schedule opcheck.sh to run every hour under root cron jobs
echo "0 * * * * root /usr/local/bin/opcheck.sh" >> /etc/crontab

# Insecure FTP Configuration with Anonymous Read/Write Access
if ! which vsftpd > /dev/null; then
    echo "FTP server is not installed. Installing now."
    apt-get update && apt-get install -y vsftpd
    # Configure FTP for anonymous read/write access
    echo "anonymous_enable=YES" >> /etc/vsftpd.conf
    echo "anon_upload_enable=YES" >> /etc/vsftpd.conf
    echo "anon_mkdir_write_enable=YES" >> /etc/vsftpd.conf
    echo "anon_other_write_enable=YES" >> /etc/vsftpd.conf
    systemctl restart vsftpd
else
    echo "FTP server is already installed and configured."
fi

# Enable Telnet
apt-get install xinetd telnetd -y
echo "service telnet" > /etc/xinetd.d/telnet
echo "{" >> /etc/xinetd.d/telnet
echo "disable = no" >> /etc/xinetd.d/telnet
echo "flags = REUSE" >> /etc/xinetd.d/telnet
echo "socket_type = stream" >> /etc/xinetd.d/telnet
echo "wait = no" >> /etc/xinetd.d/telnet
echo "user = root" >> /etc/xinetd.d/telnet
echo "server = /usr/sbin/in.telnetd" >> /etc/xinetd.d/telnet
echo "log_on_failure += USERID" >> /etc/xinetd.d/telnet
echo "}" >> /etc/xinetd.d/telnet
service xinetd restart

# Abusable Service Accounts
useradd -m -s /bin/bash rootbackup
echo "rootbackup ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

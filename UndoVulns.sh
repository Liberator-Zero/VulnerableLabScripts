#!/bin/bash

# Usernames from the original script
names=("Alice Johnson" "Bob Smith" "Carol Danvers" "David Banner" "Eve Polastri" "Frank Castle" "Grace Hopper" "Harry Potter" "Ivy Doe" "John Snow" "backupaccount" "rootbackup")

# Remove user accounts and their home directories
for name in "${names[@]}"; do
    username=$(echo "${name}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    userdel -r $username
done

# Remove SSH keys generated for root and backupaccount
rm -rf /root/.ssh
rm -rf /home/backupaccount/.ssh

# Restore SSH configuration
sed -i '/PermitRootLogin yes/d' /etc/ssh/sshd_config
sed -i '/AllowUsers/d' /etc/ssh/sshd_config

# Disable anonymous FTP access
if which vsftpd > /dev/null; then
    sed -i '/anonymous_enable=YES/d' /etc/vsftpd.conf
    sed -i '/anon_upload_enable=YES/d' /etc/vsftpd.conf
    sed -i '/anon_mkdir_write_enable=YES/d' /etc/vsftpd.conf
    sed -i '/anon_other_write_enable=YES/d' /etc/vsftpd.conf
    systemctl restart vsftpd
fi

# Remove the vulnerable script and its cron job
rm -f /usr/local/bin/opcheck.sh
sed -i '/opcheck.sh/d' /etc/crontab

# Restore file permissions for security-sensitive files
chmod 644 /etc/passwd
chmod 755 /usr/bin/tail

# Remove added telnet service configuration if it exists
if [ -f /etc/xinetd.d/telnet ]; then
    rm -f /etc/xinetd.d/telnet
    service xinetd restart
fi

# Remove any additional directories created
rm -rf /backups

echo "Reversion complete. System restored to a safer configuration."
